# Rails Authentication Patterns Guide

Comprehensive patterns for secure user authentication in Rails APIs.

---

## Table of Contents

1. [Devise with JWT](#devise-with-jwt)
2. [Token-Based Authentication](#token-based-authentication)
3. [OAuth Integration](#oauth-integration)
4. [Session Management](#session-management)
5. [Password Security](#password-security)
6. [Two-Factor Authentication](#two-factor-authentication)
7. [API Key Authentication](#api-key-authentication)

---

## Devise with JWT

### Setup and Configuration

**Good Example:**
```ruby
# Gemfile
gem 'devise'
gem 'devise-jwt'

# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
end

# app/models/jwt_denylist.rb
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end

# config/initializers/devise.rb
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/logout$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end

# config/routes.rb
Rails.application.routes.draw do
  devise_for :users,
    path: 'api/v1',
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
    controllers: {
      sessions: 'api/v1/sessions',
      registrations: 'api/v1/registrations'
    }
end

# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: {
          message: 'Logged in successfully',
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            message: 'Logged out successfully'
          }, status: :ok
        else
          render json: {
            message: 'No active session'
          }, status: :unauthorized
        end
      end
    end
  end
end

# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            message: 'Signed up successfully',
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :created
        else
          render json: {
            message: 'Signup failed',
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= super || User.find_by(id: jwt_payload['sub'])
  end

  def jwt_payload
    JWT.decode(
      request.headers['Authorization']&.split(' ')&.last,
      Rails.application.credentials.devise_jwt_secret_key
    ).first
  rescue
    {}
  end
end
```

**Client Usage:**
```javascript
// Login
fetch('https://api.example.com/api/v1/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    user: { email: 'user@example.com', password: 'password123' }
  })
})
.then(response => {
  const token = response.headers.get('Authorization');
  localStorage.setItem('jwt_token', token);
  return response.json();
});

// Authenticated request
fetch('https://api.example.com/api/v1/posts', {
  headers: {
    'Authorization': localStorage.getItem('jwt_token')
  }
});
```

**When to Use:**
- API-only Rails applications
- Mobile app backends
- Single-page applications (SPA)
- Need stateless authentication

---

## Token-Based Authentication

### Custom Token Implementation

**Good Example:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :access_tokens, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  def generate_access_token
    access_tokens.create!(
      token: SecureRandom.hex(32),
      expires_at: 30.days.from_now
    )
  end
end

# app/models/access_token.rb
class AccessToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }

  def expired?
    expires_at < Time.current
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def active?
    !expired? && revoked_at.nil?
  end
end

# app/controllers/api/v1/authentication_controller.rb
module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_user!, only: [:login]

      # POST /api/v1/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = user.generate_access_token
          render json: {
            access_token: token.token,
            expires_at: token.expires_at,
            user: UserSerializer.new(user)
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' },
                 status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def logout
        current_token.revoke!
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      # POST /api/v1/refresh
      def refresh
        if current_token.expires_at < 7.days.from_now
          new_token = current_user.generate_access_token
          current_token.revoke!

          render json: {
            access_token: new_token.token,
            expires_at: new_token.expires_at
          }, status: :ok
        else
          render json: { message: 'Token still valid' }, status: :ok
        end
      end
    end
  end
end

# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        @current_token = AccessToken.active.find_by(token: token)

        unless @current_token&.active?
          render json: { error: 'Invalid or expired token' },
                 status: :unauthorized
        end
      end

      def current_user
        @current_user ||= @current_token&.user
      end

      def current_token
        @current_token
      end
    end
  end
end
```

**Migration:**
```ruby
class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :access_tokens, :token, unique: true
    add_index :access_tokens, [:expires_at, :revoked_at]
  end
end
```

**When to Use:**
- Full control over token lifecycle
- Custom expiration logic
- Token revocation needed
- Simpler than OAuth

---

## OAuth Integration

### OmniAuth Configuration

**Good Example:**
```ruby
# Gemfile
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'

# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id),
    Rails.application.credentials.dig(:google, :client_secret),
    {
      scope: 'email,profile',
      prompt: 'select_account',
      image_aspect_ratio: 'square',
      image_size: 50
    }

  provider :github,
    Rails.application.credentials.dig(:github, :client_id),
    Rails.application.credentials.dig(:github, :client_secret),
    scope: 'user:email'
end

# app/models/user.rb
class User < ApplicationRecord
  has_many :authentications, dependent: :destroy

  def self.from_omniauth(auth)
    authentication = Authentication.find_by(
      provider: auth.provider,
      uid: auth.uid
    )

    if authentication
      authentication.user
    else
      create_from_omniauth(auth)
    end
  end

  def self.create_from_omniauth(auth)
    transaction do
      user = User.create!(
        email: auth.info.email,
        name: auth.info.name,
        avatar_url: auth.info.image,
        password: SecureRandom.hex(32)
      )

      user.authentications.create!(
        provider: auth.provider,
        uid: auth.uid,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: Time.at(auth.credentials.expires_at)
      )

      user
    end
  end
end

# app/models/authentication.rb
class Authentication < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
end

# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/auth/:provider/callback', to: 'omniauth#callback'
      post '/auth/:provider', to: 'omniauth#request_phase'
    end
  end
end

# app/controllers/api/v1/omniauth_controller.rb
module Api
  module V1
    class OmniauthController < BaseController
      skip_before_action :authenticate_user!, only: [:callback]

      def callback
        auth = request.env['omniauth.auth']
        user = User.from_omniauth(auth)

        if user
          token = user.generate_access_token
          render json: {
            access_token: token.token,
            user: UserSerializer.new(user)
          }, status: :ok
        else
          render json: { error: 'Authentication failed' },
                 status: :unauthorized
        end
      end
    end
  end
end
```

**Migration:**
```ruby
class CreateAuthentications < ActiveRecord::Migration[7.0]
  def change
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
      t.timestamps
    end

    add_index :authentications, [:provider, :uid], unique: true
  end
end
```

**When to Use:**
- Social login (Google, GitHub, Facebook)
- Enterprise SSO integration
- Reduce password management burden

---

## Session Management

### Secure Session Configuration

**Good Example:**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :strict,
  expire_after: 2.weeks

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :validate_session

  private

  def validate_session
    if session[:expires_at] && session[:expires_at] < Time.current
      reset_session
      redirect_to login_path, alert: 'Your session has expired'
    else
      session[:expires_at] = 30.minutes.from_now
    end
  end

  def create_session(user)
    reset_session  # Prevent session fixation
    session[:user_id] = user.id
    session[:expires_at] = 30.minutes.from_now
    session[:ip_address] = request.remote_ip
    session[:user_agent] = request.user_agent
  end

  def current_user
    return nil unless session[:user_id]

    # Validate session fingerprint
    if session[:ip_address] != request.remote_ip ||
       session[:user_agent] != request.user_agent
      reset_session
      return nil
    end

    @current_user ||= User.find_by(id: session[:user_id])
  end
end
```

**When to Use:**
- Traditional web applications
- Server-rendered views
- Need server-side session state

---

## Password Security

### Best Practices

**Good Example:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  validates :password,
    length: { minimum: 12 },
    format: {
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
      message: 'must include uppercase, lowercase, number, and special character'
    },
    if: :password_digest_changed?

  validates :email, presence: true, uniqueness: true

  # Password reset
  has_secure_token :password_reset_token

  def send_password_reset
    regenerate_password_reset_token
    self.password_reset_sent_at = Time.current
    save!
    UserMailer.password_reset(self).deliver_later
  end

  def password_reset_expired?
    password_reset_sent_at < 2.hours.ago
  end

  # Account lockout after failed attempts
  def lock_access!
    update!(
      locked_at: Time.current,
      failed_attempts: 0
    )
  end

  def unlock_access!
    update!(locked_at: nil)
  end

  def locked?
    locked_at.present? && locked_at > 30.minutes.ago
  end

  def increment_failed_attempts!
    increment!(:failed_attempts)
    lock_access! if failed_attempts >= 5
  end

  def reset_failed_attempts!
    update!(failed_attempts: 0)
  end
end

# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user&.locked?
      render json: {
        error: 'Account locked due to too many failed attempts'
      }, status: :locked
    elsif user&.authenticate(params[:password])
      user.reset_failed_attempts!
      create_session(user)
      render json: { user: UserSerializer.new(user) }
    else
      user&.increment_failed_attempts!
      render json: { error: 'Invalid email or password' },
             status: :unauthorized
    end
  end
end
```

**Password Reset Flow:**
```ruby
# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /password_resets
  def create
    user = User.find_by(email: params[:email])
    user&.send_password_reset
    # Always return success to prevent email enumeration
    render json: { message: 'Password reset instructions sent' }
  end

  # PATCH /password_resets/:token
  def update
    user = User.find_by(password_reset_token: params[:token])

    if user.nil?
      render json: { error: 'Invalid reset token' }, status: :not_found
    elsif user.password_reset_expired?
      render json: { error: 'Reset token expired' }, status: :unprocessable_entity
    elsif user.update(password_params)
      user.update!(password_reset_token: nil, password_reset_sent_at: nil)
      render json: { message: 'Password reset successfully' }
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
```

**When to Use:**
- All applications with password authentication
- Security-critical applications
- Compliance requirements (HIPAA, PCI-DSS)

---

## Two-Factor Authentication

**Good Example:**
```ruby
# Gemfile
gem 'rotp'
gem 'rqrcode'

# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  def enable_two_factor!
    self.otp_secret = ROTP::Base32.random
    save!
  end

  def disable_two_factor!
    update!(otp_secret: nil)
  end

  def two_factor_enabled?
    otp_secret.present?
  end

  def verify_otp(code)
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 30, drift_ahead: 30)
  end

  def otp_provisioning_uri
    totp = ROTP::TOTP.new(otp_secret, issuer: 'MyApp')
    totp.provisioning_uri(email)
  end

  def otp_qr_code
    RQRCode::QRCode.new(otp_provisioning_uri).as_svg(module_size: 4)
  end
end

# app/controllers/api/v1/two_factor_controller.rb
module Api
  module V1
    class TwoFactorController < BaseController
      # POST /api/v1/two_factor/enable
      def enable
        current_user.enable_two_factor!
        render json: {
          secret: current_user.otp_secret,
          qr_code: current_user.otp_qr_code,
          provisioning_uri: current_user.otp_provisioning_uri
        }
      end

      # POST /api/v1/two_factor/verify
      def verify
        if current_user.verify_otp(params[:code])
          render json: { message: '2FA enabled successfully' }
        else
          render json: { error: 'Invalid code' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/two_factor/disable
      def disable
        if current_user.verify_otp(params[:code])
          current_user.disable_two_factor!
          render json: { message: '2FA disabled successfully' }
        else
          render json: { error: 'Invalid code' }, status: :unauthorized
        end
      end
    end
  end
end

# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [:create, :verify_2fa]

      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          if user.two_factor_enabled?
            # Store temporary session
            session[:pending_2fa_user_id] = user.id
            render json: { requires_2fa: true }
          else
            create_full_session(user)
          end
        else
          render json: { error: 'Invalid credentials' },
                 status: :unauthorized
        end
      end

      def verify_2fa
        user = User.find(session[:pending_2fa_user_id])

        if user.verify_otp(params[:code])
          session.delete(:pending_2fa_user_id)
          create_full_session(user)
        else
          render json: { error: 'Invalid 2FA code' },
                 status: :unauthorized
        end
      end

      private

      def create_full_session(user)
        token = user.generate_access_token
        render json: {
          access_token: token.token,
          user: UserSerializer.new(user)
        }
      end
    end
  end
end
```

**When to Use:**
- Financial applications
- Admin interfaces
- High-security requirements
- Compliance mandates

---

## API Key Authentication

**Good Example:**
```ruby
# app/models/api_key.rb
class ApiKey < ApplicationRecord
  belongs_to :user

  before_create :generate_key
  before_create :generate_secret

  validates :name, presence: true

  scope :active, -> { where(revoked_at: nil) }

  def revoke!
    update!(revoked_at: Time.current)
  end

  def active?
    revoked_at.nil?
  end

  private

  def generate_key
    self.key = "pk_#{SecureRandom.hex(16)}"
  end

  def generate_secret
    self.secret = SecureRandom.hex(32)
  end
end

# app/controllers/concerns/api_key_authenticatable.rb
module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_api_key
  end

  private

  def authenticate_with_api_key
    api_key_header = request.headers['X-API-Key']
    api_secret_header = request.headers['X-API-Secret']

    @current_api_key = ApiKey.active.find_by(
      key: api_key_header,
      secret: api_secret_header
    )

    unless @current_api_key
      render json: { error: 'Invalid API credentials' },
             status: :unauthorized
    end
  end

  def current_user
    @current_user ||= @current_api_key&.user
  end
end

# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include ApiKeyAuthenticatable
    end
  end
end
```

**When to Use:**
- Server-to-server authentication
- Third-party integrations
- Webhook endpoints
- Background job APIs
