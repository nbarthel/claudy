# rails-add-turbo-stream

Add Turbo Stream functionality to a Rails controller action

---

Enhance a controller action with Turbo Stream support for dynamic, real-time updates:

1. **Update controller action** to respond to turbo_stream format
2. **Create Turbo Stream view** (e.g., `create.turbo_stream.erb`)
3. **Add Turbo Frame** targets in the HTML views if needed
4. **Update form** to work with Turbo (add `data: { turbo: true }` if needed)
5. **Test the Turbo Stream response** in controller tests

Turbo Stream actions available:

- `append` - Add content to the end of a container
- `prepend` - Add content to the beginning of a container
- `replace` - Replace an element entirely
- `update` - Replace the content inside an element
- `remove` - Remove an element
- `before` - Insert content before an element
- `after` - Insert content after an element

Best practices:

- Use Turbo Frames for independent page sections
- Use Turbo Streams for lists and dynamic updates
- Broadcast updates for real-time features using Action Cable
- Keep views DRY by using partials
- Handle both success and error states

Example implementation:

```ruby
# Controller
def create
  @post = current_user.posts.build(post_params)

  respond_to do |format|
    if @post.save
      format.html { redirect_to @post, notice: 'Post created.' }
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render :form_update, status: :unprocessable_entity }
    end
  end
end
```

```erb
<%# create.turbo_stream.erb %>
<%= turbo_stream.prepend "posts", @post %>
<%= turbo_stream.update "new_post_form", "" %>
```
