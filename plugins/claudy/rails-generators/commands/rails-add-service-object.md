# rails-add-service-object

Create a service object to encapsulate complex business logic

---

Extract complex business logic into a well-structured service object:

1. **Create service object** in `app/services/` directory
2. **Implement clear interface** with a single public method (usually `call`)
3. **Handle success and failure** cases with clear return values
4. **Add comprehensive tests** for all scenarios
5. **Update controller** to use the service object
6. **Document the service** with clear comments

Service object patterns:

- Use for complex multi-step operations
- Use when logic spans multiple models
- Use for external API integrations
- Use for complex validations or calculations

Structure:

```ruby
# app/services/post_publisher.rb
class PostPublisher
  def initialize(post, user)
    @post = post
    @user = user
  end

  def call
    return failure('Post is already published') if @post.published?
    return failure('User not authorized') unless can_publish?

    @post.transaction do
      @post.update!(published: true, published_at: Time.current)
      notify_subscribers
      track_analytics
    end

    success(@post)
  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  def can_publish?
    @user.admin? || @post.user == @user
  end

  def notify_subscribers
    # Send notifications
  end

  def track_analytics
    # Track publishing event
  end

  def success(data)
    { success: true, data: data }
  end

  def failure(error)
    { success: false, error: error }
  end
end
```

Usage in controller:

```ruby
def publish
  result = PostPublisher.new(@post, current_user).call

  if result[:success]
    redirect_to result[:data], notice: 'Post published successfully.'
  else
    redirect_to @post, alert: result[:error]
  end
end
```
