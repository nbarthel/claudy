# Rails Background Job Patterns Guide

Comprehensive patterns for asynchronous processing and background jobs in Rails.

---

## Table of Contents

1. [Solid Queue (Rails 7.1+)](#solid-queue-rails-71)
2. [Sidekiq](#sidekiq)
3. [Job Design Patterns](#job-design-patterns)
4. [Error Handling and Retries](#error-handling-and-retries)
5. [Job Scheduling](#job-scheduling)
6. [Monitoring and Observability](#monitoring-and-observability)
7. [Testing Background Jobs](#testing-background-jobs)

---

## Solid Queue (Rails 7.1+)

### Setup and Basic Usage

**Good Example:**
```ruby
# Gemfile
gem 'solid_queue'

# config/database.yml
production:
  primary:
    <<: *default
    database: myapp_production
  queue:
    <<: *default
    database: myapp_production_queue
    migrations_paths: db/queue_migrate

# config/solid_queue.yml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: default
      threads: 3
      processes: 2
      polling_interval: 0.1
    - queues: high_priority
      threads: 5
      processes: 3
      polling_interval: 0.05

# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError

  around_perform do |job, block|
    Rails.logger.info("Starting job: #{job.class.name}")
    start_time = Time.current

    block.call

    duration = Time.current - start_time
    Rails.logger.info("Completed job: #{job.class.name} in #{duration}s")
  end
end

# app/jobs/send_welcome_email_job.rb
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome_email(user).deliver_now
  end
end

# Usage:
# Enqueue immediately
SendWelcomeEmailJob.perform_later(user.id)

# Enqueue with delay
SendWelcomeEmailJob.set(wait: 1.hour).perform_later(user.id)

# Enqueue at specific time
SendWelcomeEmailJob.set(wait_until: Date.tomorrow.noon).perform_later(user.id)
```

**When to Use:**
- Rails 7.1+ applications
- Simple background job needs
- Prefer database-backed queues
- No external dependencies (Redis)

---

## Sidekiq

### Setup and Configuration

**Good Example:**
```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-scheduler'  # For recurring jobs
gem 'sidekiq-unique-jobs'  # For job deduplication

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    network_timeout: 5,
    pool_timeout: 5
  }

  config.on(:startup) do
    schedule_file = Rails.root.join('config/sidekiq_schedule.yml')
    if File.exist?(schedule_file)
      Sidekiq::Scheduler.load_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    network_timeout: 5
  }
end

# config/sidekiq.yml
:concurrency: 10
:queues:
  - [critical, 4]
  - [high, 3]
  - [default, 2]
  - [low, 1]

# config/sidekiq_schedule.yml
cleanup_old_records:
  cron: '0 2 * * *'  # 2 AM daily
  class: CleanupOldRecordsJob
  queue: low

send_daily_digest:
  cron: '0 8 * * *'  # 8 AM daily
  class: SendDailyDigestJob
  queue: default

# app/jobs/process_payment_job.rb
class ProcessPaymentJob < ApplicationJob
  queue_as :critical

  sidekiq_options retry: 3, dead: false

  def perform(payment_id)
    payment = Payment.find(payment_id)
    PaymentProcessor.process(payment)
  end
end

# app/jobs/import_users_job.rb
class ImportUsersJob < ApplicationJob
  queue_as :low

  sidekiq_options lock: :until_executed,
                   on_conflict: :reject

  def perform(file_path)
    CSV.foreach(file_path, headers: true) do |row|
      User.create!(
        email: row['email'],
        name: row['name']
      )
    end
  end
end
```

**When to Use:**
- High-throughput job processing
- Complex job scheduling needs
- Job uniqueness/deduplication required
- Advanced monitoring needed

---

## Job Design Patterns

### Idempotent Jobs

**Good Example:**
```ruby
# app/jobs/sync_user_to_crm_job.rb
class SyncUserToCrmJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    # Check if sync already completed
    return if user.synced_to_crm_at&.> 5.minutes.ago

    # Perform sync
    response = CrmService.sync_user(user)

    # Mark as synced (idempotent marker)
    user.update!(
      synced_to_crm_at: Time.current,
      crm_external_id: response['id']
    )
  end
end
```

**Bad Example:**
```ruby
# ❌ Not idempotent - creates duplicate records
class SyncUserToCrmJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    CrmService.create_user(user)  # Creates duplicate on retry
  end
end
```

### Batch Processing Jobs

**Good Example:**
```ruby
# app/jobs/batch_process_orders_job.rb
class BatchProcessOrdersJob < ApplicationJob
  queue_as :default

  def perform(batch_size: 100)
    Order.pending.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |order|
        ProcessOrderJob.perform_later(order.id)
      end
    end
  end
end

# app/jobs/process_order_job.rb
class ProcessOrderJob < ApplicationJob
  queue_as :high

  def perform(order_id)
    order = Order.find(order_id)

    ApplicationRecord.transaction do
      order.process!
      order.send_confirmation_email
    end
  end
end
```

### Chain Jobs

**Good Example:**
```ruby
# app/jobs/export_report_job.rb
class ExportReportJob < ApplicationJob
  queue_as :default

  def perform(report_id)
    report = Report.find(report_id)

    # Generate CSV
    csv_data = ReportGenerator.to_csv(report)
    file_path = "tmp/reports/#{report.id}.csv"
    File.write(file_path, csv_data)

    # Chain to upload job
    UploadToS3Job.perform_later(file_path, report.id)
  end
end

# app/jobs/upload_to_s3_job.rb
class UploadToS3Job < ApplicationJob
  queue_as :default

  def perform(file_path, report_id)
    report = Report.find(report_id)

    # Upload to S3
    url = S3Service.upload(file_path)

    # Update report
    report.update!(file_url: url)

    # Chain to notification job
    SendReportReadyNotificationJob.perform_later(report.id)

    # Cleanup temp file
    File.delete(file_path)
  end
end

# app/jobs/send_report_ready_notification_job.rb
class SendReportReadyNotificationJob < ApplicationJob
  queue_as :high

  def perform(report_id)
    report = Report.find(report_id)
    ReportMailer.report_ready(report).deliver_now
  end
end
```

### Parallel Processing with Wait

**Good Example:**
```ruby
# app/jobs/aggregate_metrics_job.rb
class AggregateMetricsJob < ApplicationJob
  queue_as :default

  def perform(date)
    # Launch parallel jobs
    jobs = []

    jobs << CalculateUserMetricsJob.perform_later(date)
    jobs << CalculateRevenueMetricsJob.perform_later(date)
    jobs << CalculateEngagementMetricsJob.perform_later(date)

    # Wait for all jobs to complete (Rails 7.1+)
    ActiveJob.wait_all(jobs)

    # Aggregate results
    FinalizeMetricsReportJob.perform_later(date)
  end
end
```

**When to Use:**
- Idempotent: All jobs (prevents duplicate side effects)
- Batch: Large datasets, rate-limited APIs
- Chain: Multi-step workflows
- Parallel: Independent tasks that can run concurrently

---

## Error Handling and Retries

### Exponential Backoff

**Good Example:**
```ruby
# app/jobs/call_external_api_job.rb
class CallExternalApiJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff: 3s, 18s, 83s, 403s, 2000s
  retry_on ExternalApiError,
           wait: :exponentially_longer,
           attempts: 5

  # Don't retry on client errors (4xx)
  discard_on ExternalApiClientError

  # Custom retry logic
  retry_on ExternalApiRateLimitError, wait: 1.hour, attempts: 3

  def perform(user_id)
    user = User.find(user_id)

    begin
      ExternalApi.sync_user(user)
    rescue ExternalApi::ConnectionError => e
      # Log and re-raise to trigger retry
      Rails.logger.error("API connection failed: #{e.message}")
      raise ExternalApiError, e.message
    rescue ExternalApi::ClientError => e
      # Don't retry on 4xx errors
      Rails.logger.error("API client error: #{e.message}")
      raise ExternalApiClientError, e.message
    rescue ExternalApi::RateLimitError => e
      # Specific handling for rate limits
      Rails.logger.warn("API rate limit hit: #{e.message}")
      raise ExternalApiRateLimitError, e.message
    end
  end
end

# app/services/external_api.rb
module ExternalApi
  class Error < StandardError; end
  class ConnectionError < Error; end
  class ClientError < Error; end
  class RateLimitError < Error; end

  def self.sync_user(user)
    response = Faraday.post(
      "#{ENV['API_URL']}/users",
      user.to_json
    )

    case response.status
    when 200..299
      response.body
    when 400..499
      raise ClientError, "Status: #{response.status}"
    when 429
      raise RateLimitError, "Rate limit exceeded"
    when 500..599
      raise ConnectionError, "Server error: #{response.status}"
    else
      raise Error, "Unexpected status: #{response.status}"
    end
  end
end
```

### Dead Letter Queue Handling

**Good Example:**
```ruby
# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    block.call
  rescue => error
    if job.executions >= job.class.retry_limit
      # Job exhausted all retries - send to dead letter queue
      DeadLetterQueue.create!(
        job_class: job.class.name,
        arguments: job.arguments,
        error_class: error.class.name,
        error_message: error.message,
        backtrace: error.backtrace.first(10),
        executions: job.executions
      )

      # Notify team
      ExceptionNotifier.notify_exception(error, data: {
        job: job.class.name,
        arguments: job.arguments
      })
    end

    raise
  end
end

# app/models/dead_letter_queue.rb
class DeadLetterQueue < ApplicationRecord
  validates :job_class, presence: true
  validates :error_class, presence: true

  scope :unresolved, -> { where(resolved_at: nil) }

  def retry!
    job_class.constantize.perform_later(*arguments)
    update!(resolved_at: Time.current, retried_at: Time.current)
  end

  def discard!
    update!(resolved_at: Time.current, discarded_at: Time.current)
  end
end
```

**When to Use:**
- Exponential backoff: Transient errors (network, timeouts)
- Dead letter queue: Track permanently failed jobs
- Custom retry logic: API rate limits, scheduled maintenance

---

## Job Scheduling

### Recurring Jobs with Solid Queue

**Good Example:**
```ruby
# app/jobs/recurring/cleanup_old_sessions_job.rb
module Recurring
  class CleanupOldSessionsJob < ApplicationJob
    queue_as :low

    # Use Solid Queue's recurring jobs feature
    def self.schedule
      set(wait: next_run_time).perform_later
    end

    def self.next_run_time
      # Run at 2 AM daily
      tomorrow_2am = Date.tomorrow.beginning_of_day + 2.hours
      tomorrow_2am > Time.current ? tomorrow_2am : tomorrow_2am + 1.day
    end

    def perform
      deleted_count = Session.where('updated_at < ?', 30.days.ago).delete_all
      Rails.logger.info("Cleaned up #{deleted_count} old sessions")

      # Schedule next run
      self.class.schedule
    end
  end
end

# config/initializers/recurring_jobs.rb
Rails.application.config.after_initialize do
  if defined?(Solid::Queue) && Rails.env.production?
    Recurring::CleanupOldSessionsJob.schedule
  end
end
```

### Cron Jobs with Sidekiq-Scheduler

**Good Example:**
```ruby
# config/sidekiq_schedule.yml
cleanup_expired_tokens:
  cron: '0 */6 * * *'  # Every 6 hours
  class: CleanupExpiredTokensJob
  queue: low
  description: 'Remove expired access tokens'

send_weekly_digest:
  cron: '0 9 * * 1'  # Monday 9 AM
  class: SendWeeklyDigestJob
  queue: default
  description: 'Send weekly digest emails'

generate_analytics_report:
  cron: '0 1 * * *'  # Daily at 1 AM
  class: GenerateAnalyticsReportJob
  queue: low
  description: 'Generate daily analytics reports'

# app/jobs/cleanup_expired_tokens_job.rb
class CleanupExpiredTokensJob < ApplicationJob
  queue_as :low

  def perform
    expired_count = AccessToken.where('expires_at < ?', Time.current).delete_all
    Rails.logger.info("Deleted #{expired_count} expired tokens")
  end
end
```

**When to Use:**
- Solid Queue recurring: Simple periodic tasks
- Sidekiq-Scheduler: Complex cron schedules
- At/queue pattern: User-triggered scheduled jobs

---

## Monitoring and Observability

### Job Performance Tracking

**Good Example:**
```ruby
# app/jobs/concerns/job_instrumentation.rb
module JobInstrumentation
  extend ActiveSupport::Concern

  included do
    around_perform do |job, block|
      start_time = Time.current
      memory_before = memory_usage

      begin
        block.call

        duration = Time.current - start_time
        memory_delta = memory_usage - memory_before

        log_metrics(job, duration, memory_delta, :success)
      rescue => error
        duration = Time.current - start_time
        memory_delta = memory_usage - memory_before

        log_metrics(job, duration, memory_delta, :failed, error)
        raise
      end
    end
  end

  private

  def log_metrics(job, duration, memory_delta, status, error = nil)
    metrics = {
      job_class: job.class.name,
      job_id: job.job_id,
      queue: job.queue_name,
      duration: duration,
      memory_delta_mb: memory_delta,
      status: status,
      executions: job.executions
    }

    metrics[:error] = error.class.name if error

    Rails.logger.info("Job metrics: #{metrics.to_json}")

    # Send to monitoring service (DataDog, New Relic, etc.)
    StatsD.timing("jobs.#{job.class.name}.duration", duration * 1000)
    StatsD.increment("jobs.#{job.class.name}.#{status}")
  end

  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
  end
end

# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  include JobInstrumentation
end
```

### Sidekiq Web UI

**Good Example:**
```ruby
# config/routes.rb
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end
end

# config/initializers/sidekiq.rb
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  ActiveSupport::SecurityUtils.secure_compare(
    Digest::SHA256.hexdigest(user),
    Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])
  ) &
  ActiveSupport::SecurityUtils.secure_compare(
    Digest::SHA256.hexdigest(password),
    Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])
  )
end
```

**When to Use:**
- Job instrumentation: All applications
- Sidekiq Web UI: Development and staging (protected)
- Metrics: Production monitoring

---

## Testing Background Jobs

**Good Example:**
```ruby
# spec/jobs/send_welcome_email_job_spec.rb
require 'rails_helper'

RSpec.describe SendWelcomeEmailJob, type: :job do
  describe '#perform' do
    let(:user) { create(:user) }

    it 'sends welcome email' do
      expect {
        described_class.perform_now(user.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq('Welcome to MyApp')
    end

    it 'enqueues job' do
      expect {
        described_class.perform_later(user.id)
      }.to have_enqueued_job(described_class)
        .with(user.id)
        .on_queue('default')
    end

    it 'handles missing user gracefully' do
      expect {
        described_class.perform_now(999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'with retries' do
      before do
        allow(UserMailer).to receive(:welcome_email)
          .and_raise(Net::SMTPServerBusy)
      end

      it 'retries on transient errors' do
        expect {
          described_class.perform_now(user.id)
        }.to raise_error(Net::SMTPServerBusy)

        expect(described_class).to have_been_enqueued.at_most(5).times
      end
    end
  end
end

# spec/support/active_job.rb
RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.before(:each, type: :job) do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
```

**When to Use:**
- Test job enqueuing (not just performing)
- Test retry behavior
- Test side effects (emails, API calls)
