# rails-generate-model

Generate a new Rails model with migrations, validations, and tests

---

Create a new Rails model following best practices:

1. **Generate the model** using Rails generator with appropriate fields
2. **Add validations** to the model based on field types and business logic
3. **Create associations** if related models are mentioned
4. **Add indexes** for foreign keys and frequently queried fields
5. **Write RSpec tests** (or Minitest if that's what the project uses) covering:
   - Validations
   - Associations
   - Any custom methods
6. **Run the migration** to ensure it works

Rails conventions to follow:

- Use `belongs_to`, `has_many`, `has_one` for associations
- Add `dependent: :destroy` or `dependent: :nullify` where appropriate
- Use appropriate column types (string, text, integer, decimal, boolean, datetime, references)
- Add `null: false` constraints where fields are required
- Use `default:` for fields with default values
- Include timestamps unless explicitly told not to

Example model structure:

```ruby
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true

  scope :published, -> { where(published: true) }
end
```
