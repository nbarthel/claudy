# Rails Real-Time Patterns Guide

Comprehensive patterns for implementing real-time features in Rails APIs using Turbo Streams and Action Cable.

---

## Table of Contents

1. [Turbo Streams](#turbo-streams)
2. [Action Cable WebSockets](#action-cable-websockets)
3. [Broadcasting Patterns](#broadcasting-patterns)
4. [Authentication](#authentication)
5. [Presence Channels](#presence-channels)
6. [Performance Optimization](#performance-optimization)
7. [Testing Real-Time Features](#testing-real-time-features)

---

## Turbo Streams

### Basic Setup

**Good Example:**
```ruby
# Gemfile
gem 'turbo-rails'

# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :posts do
        resources :comments, only: [:create, :destroy]
      end
    end
  end
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # Broadcast changes to all subscribers
  after_create_commit -> { broadcast_append_to_post }
  after_update_commit -> { broadcast_update_to_post }
  after_destroy_commit -> { broadcast_remove_to_post }

  private

  def broadcast_append_to_post
    broadcast_append_to(
      "post_#{post_id}_comments",
      partial: 'comments/comment',
      locals: { comment: self },
      target: 'comments'
    )
  end

  def broadcast_update_to_post
    broadcast_update_to(
      "post_#{post_id}_comments",
      partial: 'comments/comment',
      locals: { comment: self },
      target: dom_id(self)
    )
  end

  def broadcast_remove_to_post
    broadcast_remove_to(
      "post_#{post_id}_comments",
      target: dom_id(self)
    )
  end
end

# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < BaseController
      def create
        @comment = current_user.comments.build(comment_params)
        @comment.post_id = params[:post_id]

        if @comment.save
          # Turbo will broadcast automatically via callbacks
          render json: @comment, status: :created
        else
          render json: { errors: @comment.errors },
                 status: :unprocessable_entity
        end
      end

      def destroy
        @comment = current_user.comments.find(params[:id])
        @comment.destroy

        head :no_content
      end

      private

      def comment_params
        params.require(:comment).permit(:body)
      end
    end
  end
end
```

### Custom Turbo Streams

**Good Example:**
```ruby
# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user

  after_create_commit :broadcast_to_user

  private

  def broadcast_to_user
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{user_id}_notifications",
      target: 'notifications',
      html: ApplicationController.render(
        partial: 'notifications/notification',
        locals: { notification: self }
      )
    )

    # Also broadcast count update
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user_id}_notifications",
      target: 'notification_count',
      html: "<span id='notification_count'>#{user.notifications.unread.count}</span>"
    )
  end
end
```

**When to Use:**
- Real-time UI updates
- Collaborative editing
- Live notifications
- Activity feeds

---

## Action Cable WebSockets

### Channel Setup

**Good Example:**
```ruby
# config/cable.yml
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: myapp_production

# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.email
    end

    private

    def find_verified_user
      token = request.params[:token] || cookies.encrypted[:token]

      if verified_user = User.find_by(api_token: token)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end

# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
    private

    def current_user
      connection.current_user
    end
  end
end
```

### Chat Channel Example

**Good Example:**
```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to room
    room = ChatRoom.find(params[:room_id])

    # Verify user has access
    reject unless room.participants.include?(current_user)

    stream_from "chat_room_#{params[:room_id]}"

    # Broadcast user joined
    broadcast_user_joined
  end

  def unsubscribed
    # Broadcast user left
    broadcast_user_left

    # Cleanup
    stop_all_streams
  end

  def receive(data)
    # Handle incoming message
    message = current_user.messages.create!(
      chat_room_id: params[:room_id],
      body: data['body']
    )

    # Broadcast to all subscribers
    ChatChannel.broadcast_to(
      "chat_room_#{params[:room_id]}",
      {
        type: 'message',
        message: MessageSerializer.new(message).as_json,
        user: UserSerializer.new(current_user).as_json
      }
    )
  end

  def typing(data)
    # Broadcast typing indicator
    ActionCable.server.broadcast(
      "chat_room_#{params[:room_id]}_typing",
      {
        type: 'typing',
        user_id: current_user.id,
        user_name: current_user.name,
        typing: data['typing']
      }
    )
  end

  private

  def broadcast_user_joined
    ActionCable.server.broadcast(
      "chat_room_#{params[:room_id]}",
      {
        type: 'user_joined',
        user: UserSerializer.new(current_user).as_json
      }
    )
  end

  def broadcast_user_left
    ActionCable.server.broadcast(
      "chat_room_#{params[:room_id]}",
      {
        type: 'user_left',
        user_id: current_user.id
      }
    )
  end
end

# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validates :body, presence: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ChatChannel.broadcast_to(
      "chat_room_#{chat_room_id}",
      {
        type: 'message',
        message: MessageSerializer.new(self).as_json,
        user: UserSerializer.new(user).as_json
      }
    )
  end
end
```

**Client-Side (JavaScript):**
```javascript
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

export default class ChatChannel {
  constructor(roomId, token) {
    this.roomId = roomId;
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ChatChannel",
        room_id: roomId,
        token: token
      },
      {
        connected: () => {
          console.log(`Connected to chat room ${roomId}`);
        },

        disconnected: () => {
          console.log(`Disconnected from chat room ${roomId}`);
        },

        received: (data) => {
          switch(data.type) {
            case 'message':
              this.handleMessage(data);
              break;
            case 'user_joined':
              this.handleUserJoined(data);
              break;
            case 'user_left':
              this.handleUserLeft(data);
              break;
          }
        }
      }
    );
  }

  sendMessage(body) {
    this.subscription.send({ body: body });
  }

  sendTyping(isTyping) {
    this.subscription.perform('typing', { typing: isTyping });
  }

  handleMessage(data) {
    // Append message to UI using safe DOM methods
    const messagesContainer = document.getElementById('messages');
    const messageElement = this.createMessageElement(data.message, data.user);
    messagesContainer.appendChild(messageElement);
  }

  handleUserJoined(data) {
    console.log(`${data.user.name} joined`);
  }

  handleUserLeft(data) {
    console.log(`User ${data.user_id} left`);
  }

  createMessageElement(message, user) {
    // Use safe DOM methods instead of innerHTML
    const div = document.createElement('div');
    div.className = 'message';

    const strong = document.createElement('strong');
    strong.textContent = `${user.name}:`;

    const span = document.createElement('span');
    span.textContent = message.body;

    const small = document.createElement('small');
    small.textContent = message.created_at;

    div.appendChild(strong);
    div.appendChild(document.createTextNode(' '));
    div.appendChild(span);
    div.appendChild(document.createTextNode(' '));
    div.appendChild(small);

    return div;
  }

  disconnect() {
    this.subscription.unsubscribe();
  }
}

// Usage:
const chat = new ChatChannel(roomId, authToken);
chat.sendMessage("Hello, world!");
```

**When to Use:**
- Real-time chat/messaging
- Live collaboration
- Multiplayer features
- Live updates requiring bidirectional communication

---

## Broadcasting Patterns

### Targeted Broadcasting

**Good Example:**
```ruby
# app/services/notification_broadcaster.rb
class NotificationBroadcaster
  def self.broadcast_to_user(user, notification)
    ActionCable.server.broadcast(
      "notifications:#{user.id}",
      {
        type: 'notification',
        notification: NotificationSerializer.new(notification).as_json
      }
    )
  end

  def self.broadcast_to_team(team, message)
    team.members.each do |member|
      ActionCable.server.broadcast(
        "team:#{team.id}:user:#{member.id}",
        {
          type: 'team_message',
          message: message
        }
      )
    end
  end

  def self.broadcast_to_all(message)
    ActionCable.server.broadcast(
      'global_notifications',
      {
        type: 'announcement',
        message: message
      }
    )
  end
end
```

### Background Job Broadcasting

**Good Example:**
```ruby
# app/jobs/report_generation_job.rb
class ReportGenerationJob < ApplicationJob
  queue_as :default

  def perform(user_id, report_id)
    user = User.find(user_id)
    report = Report.find(report_id)

    # Broadcast progress updates
    broadcast_progress(user, 0, "Starting report generation...")

    # Generate report
    report.generate! do |progress|
      broadcast_progress(user, progress, "Generating... #{progress}%")
    end

    broadcast_progress(user, 100, "Report completed!")

    # Broadcast completion
    ActionCable.server.broadcast(
      "reports:#{user_id}",
      {
        type: 'report_completed',
        report: ReportSerializer.new(report).as_json
      }
    )
  end

  private

  def broadcast_progress(user, percentage, message)
    ActionCable.server.broadcast(
      "reports:#{user.id}",
      {
        type: 'progress_update',
        percentage: percentage,
        message: message
      }
    )
  end
end
```

**When to Use:**
- User-specific notifications
- Team/group messaging
- Global announcements
- Long-running job progress

---

## Authentication

### Token-Based Authentication

**Good Example:**
```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Try multiple authentication methods
      if verified_user = authenticate_from_token ||
                         authenticate_from_session ||
                         authenticate_from_cookie
        verified_user
      else
        reject_unauthorized_connection
      end
    end

    def authenticate_from_token
      token = request.params[:token]
      return nil unless token

      # Verify JWT token
      begin
        decoded = JWT.decode(
          token,
          Rails.application.credentials.secret_key_base,
          true,
          { algorithm: 'HS256' }
        ).first

        User.find_by(id: decoded['user_id'])
      rescue JWT::DecodeError
        nil
      end
    end

    def authenticate_from_session
      user_id = request.session[:user_id]
      User.find_by(id: user_id) if user_id
    end

    def authenticate_from_cookie
      token = cookies.encrypted[:auth_token]
      AccessToken.active.find_by(token: token)&.user
    end
  end
end
```

**Client-Side:**
```javascript
// Connect with token
const token = localStorage.getItem('auth_token');
const cable = ActionCable.createConsumer(
  `ws://localhost:3000/cable?token=${token}`
);
```

**When to Use:**
- API-only authentication
- Mobile clients
- Cross-origin connections

---

## Presence Channels

**Good Example:**
```ruby
# app/channels/presence_channel.rb
class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence:#{params[:room_id]}"

    # Add user to online list
    add_user_to_presence

    # Broadcast updated presence
    broadcast_presence
  end

  def unsubscribed
    # Remove user from online list
    remove_user_from_presence

    # Broadcast updated presence
    broadcast_presence
  end

  def appear(data)
    # Update user status
    update_user_status('online')
    broadcast_presence
  end

  def away(data)
    # Update user status
    update_user_status('away')
    broadcast_presence
  end

  private

  def add_user_to_presence
    $redis_pool.with do |redis|
      redis.sadd("presence:room:#{params[:room_id]}", current_user.id)
      redis.hset(
        "presence:user:#{current_user.id}",
        'status', 'online',
        'last_seen', Time.current.to_i
      )
    end
  end

  def remove_user_from_presence
    $redis_pool.with do |redis|
      redis.srem("presence:room:#{params[:room_id]}", current_user.id)
      redis.del("presence:user:#{current_user.id}")
    end
  end

  def update_user_status(status)
    $redis_pool.with do |redis|
      redis.hset(
        "presence:user:#{current_user.id}",
        'status', status,
        'last_seen', Time.current.to_i
      )
    end
  end

  def broadcast_presence
    online_users = get_online_users

    ActionCable.server.broadcast(
      "presence:#{params[:room_id]}",
      {
        type: 'presence',
        users: online_users
      }
    )
  end

  def get_online_users
    $redis_pool.with do |redis|
      user_ids = redis.smembers("presence:room:#{params[:room_id]}")

      user_ids.map do |user_id|
        user_data = redis.hgetall("presence:user:#{user_id}")
        user = User.find(user_id)

        {
          id: user.id,
          name: user.name,
          avatar_url: user.avatar_url,
          status: user_data['status'],
          last_seen: user_data['last_seen']
        }
      end
    end
  end
end
```

**When to Use:**
- Online/offline status
- "Who's viewing this page"
- Collaborative editing presence
- Chat room participants

---

## Performance Optimization

### Connection Pooling

**Good Example:**
```ruby
# config/cable.yml
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>
  channel_prefix: myapp_production
  pool: 5  # Connection pool size

# config/puma.rb
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

# Action Cable mounts on same server
plugin :tmp_restart
```

### Selective Broadcasting

**Good Example:**
```ruby
# app/models/post.rb
class Post < ApplicationRecord
  after_update_commit :broadcast_if_published

  private

  def broadcast_if_published
    # Only broadcast if published
    return unless published?

    # Only broadcast if title or body changed
    return unless saved_change_to_title? || saved_change_to_body?

    ActionCable.server.broadcast(
      'posts:updates',
      PostSerializer.new(self).as_json
    )
  end
end
```

### Message Throttling

**Good Example:**
```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  TYPING_THROTTLE_SECONDS = 3

  def typing(data)
    # Throttle typing indicator
    cache_key = "typing:#{params[:room_id]}:#{current_user.id}"

    unless Rails.cache.exist?(cache_key)
      broadcast_typing_status(data['typing'])
      Rails.cache.write(cache_key, true, expires_in: TYPING_THROTTLE_SECONDS)
    end
  end

  private

  def broadcast_typing_status(is_typing)
    ActionCable.server.broadcast(
      "chat_room_#{params[:room_id]}_typing",
      {
        user_id: current_user.id,
        typing: is_typing
      }
    )
  end
end
```

**When to Use:**
- High-traffic applications
- Frequent updates
- Battery/bandwidth concerns

---

## Testing Real-Time Features

**Good Example:**
```ruby
# spec/channels/chat_channel_spec.rb
require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
  let(:user) { create(:user) }
  let(:room) { create(:chat_room) }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it 'subscribes to room stream' do
      subscribe(room_id: room.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("chat_room_#{room.id}")
    end

    it 'rejects unauthorized users' do
      other_room = create(:chat_room)

      subscribe(room_id: other_room.id)

      expect(subscription).to be_rejected
    end
  end

  describe '#receive' do
    before { subscribe(room_id: room.id) }

    it 'broadcasts message to room' do
      expect {
        perform :receive, body: 'Hello, world!'
      }.to have_broadcasted_to("chat_room_#{room.id}")
        .with(hash_including(type: 'message'))
    end

    it 'creates message record' do
      expect {
        perform :receive, body: 'Hello, world!'
      }.to change { Message.count }.by(1)

      message = Message.last
      expect(message.body).to eq('Hello, world!')
      expect(message.user).to eq(user)
    end
  end

  describe '#typing' do
    before { subscribe(room_id: room.id) }

    it 'broadcasts typing status' do
      expect {
        perform :typing, typing: true
      }.to have_broadcasted_to("chat_room_#{room.id}_typing")
        .with(hash_including(user_id: user.id, typing: true))
    end
  end
end
```

**When to Use:**
- All channel implementations
- Verify subscriptions
- Test broadcasts
- Authentication checks
