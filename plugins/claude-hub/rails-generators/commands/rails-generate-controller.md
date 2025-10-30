# rails-generate-controller

Generate a Rails controller with actions, views, and tests

---

Create a new Rails controller following RESTful conventions:

1. **Generate the controller** with specified actions
2. **Implement controller actions** with:
   - Strong parameters
   - Proper error handling
   - Flash messages for user feedback
   - Redirects or renders as appropriate
3. **Create view templates** for each action (if applicable)
4. **Add routes** to config/routes.rb (use resources when appropriate)
5. **Write controller tests** covering:
   - Successful requests
   - Failed validations
   - Authorization checks
   - Edge cases

RESTful actions to consider:

- `index` - List all resources
- `show` - Display a single resource
- `new` - Form for creating a resource
- `create` - Process creation
- `edit` - Form for updating a resource
- `update` - Process update
- `destroy` - Delete a resource

Controller best practices:

- Keep actions thin, move logic to models or service objects
- Use before_actions for common setup (e.g., `set_post`, authentication)
- Respond to multiple formats (HTML, JSON, Turbo Stream)
- Use strong parameters to whitelist attributes
- Handle errors gracefully with proper HTTP status codes

Example controller structure:

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @posts = Post.published.order(created_at: :desc)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: 'Post created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
```
