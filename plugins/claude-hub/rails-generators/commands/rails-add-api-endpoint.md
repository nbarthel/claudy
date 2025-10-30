# rails-add-api-endpoint

Create a JSON API endpoint in a Rails application

---

Add a new API endpoint following Rails API best practices:

1. **Create or update API controller** in `app/controllers/api/v1/`
2. **Implement the endpoint** with:
   - JSON response format
   - Proper HTTP status codes
   - Error handling
   - Pagination (for list endpoints)
   - Authentication/authorization if needed
3. **Add route** under API namespace
4. **Use serializer or jbuilder** for response formatting
5. **Write API tests** including:
   - Successful requests
   - Error cases
   - Authentication tests
   - Response format validation
6. **Document the API** (consider adding to README or API docs)

API best practices:

- Use proper HTTP verbs (GET, POST, PUT, PATCH, DELETE)
- Return appropriate status codes (200, 201, 204, 400, 401, 404, 422, 500)
- Version your API (namespace under /api/v1/)
- Use consistent response format
- Implement pagination for list endpoints
- Include error details in error responses
- Use authentication tokens (JWT, API keys)

Example controller:

```ruby
module Api
  module V1
    class PostsController < ApiController
      before_action :authenticate_api_user!
      before_action :set_post, only: [:show, :update, :destroy]

      def index
        @posts = Post.published
                     .page(params[:page])
                     .per(params[:per_page] || 25)

        render json: {
          posts: @posts.as_json(only: [:id, :title, :body, :created_at]),
          meta: pagination_meta(@posts)
        }
      end

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: @post, status: :created
        else
          render json: { errors: @post.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body, :published)
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
```

Routes:

```ruby
namespace :api do
  namespace :v1 do
    resources :posts
  end
end
```
