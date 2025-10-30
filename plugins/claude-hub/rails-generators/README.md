# Rails Workflow Plugin

A comprehensive Claude Code plugin for Ruby on Rails development workflows. This plugin provides slash commands that automate common Rails development tasks while following Rails conventions and best practices.

## Installation

1. Copy the `.claude` directory to your Rails project root:

```bash
cp -r plugins/rails-workflow/.claude /path/to/your/rails/project/
```

2. Verify installation by running `/help` in Claude Code

## Available Commands

### Model Generation

#### `/rails-generate-model`

Generate a new Rails model with migrations, validations, associations, and tests.

**Example usage:**

```
User: /rails-generate-model
Claude: I'll help you create a new Rails model. What should I name it and what fields does it need?
```

**Features:**

- Automatic validation generation
- Association setup
- Index creation for foreign keys
- RSpec/Minitest test generation
- Migration best practices

### Controller Generation

#### `/rails-generate-controller`

Generate a RESTful Rails controller with actions, views, and tests.

**Example usage:**

```
User: /rails-generate-controller Posts index show new create edit update destroy
```

**Features:**

- RESTful action implementation
- Strong parameters
- Before actions
- View templates
- Controller tests
- Proper error handling

### Turbo/Hotwire

#### `/rails-add-turbo-stream`

Add Turbo Stream functionality to controller actions for dynamic updates.

**Example usage:**

```
User: /rails-add-turbo-stream for the create action in PostsController
```

**Features:**

- Turbo Stream view generation
- Multiple format support
- Frame targeting
- Real-time update patterns

### Service Objects

#### `/rails-add-service-object`

Create service objects to encapsulate complex business logic.

**Example usage:**

```
User: /rails-add-service-object to handle post publishing logic
```

**Features:**

- Clear service object structure
- Success/failure handling
- Transaction support
- Comprehensive testing

### Testing

#### `/rails-setup-rspec`

Configure RSpec testing framework with best practices.

**Example usage:**

```
User: /rails-setup-rspec
```

**Features:**

- RSpec installation
- FactoryBot configuration
- Shoulda Matchers setup
- Test directory structure

### API Development

#### `/rails-add-api-endpoint`

Create JSON API endpoints following Rails API conventions.

**Example usage:**

```
User: /rails-add-api-endpoint for posts
```

**Features:**

- API versioning
- JSON response formatting
- Pagination support
- Error handling
- API tests

## Best Practices

This plugin enforces Rails best practices including:

- RESTful routing and controller design
- Strong parameters for mass assignment protection
- Service objects for complex business logic
- Comprehensive testing (models, controllers, requests)
- Turbo/Hotwire for modern Rails UX
- API versioning and proper HTTP status codes

## Project Structure

The plugin follows standard Rails conventions:

```
app/
├── controllers/     # RESTful controllers
├── models/          # ActiveRecord models
├── services/        # Service objects
├── views/           # ERB templates
└── ...

spec/                # RSpec tests
├── models/
├── controllers/
├── requests/
└── ...
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow Rails and Ruby style guides
2. Include tests for new commands
3. Update documentation
4. Test with multiple Rails versions

## License

MIT License - see LICENSE file

## Version

0.1.0 - Initial release

## Requirements

- Ruby 3.0+
- Rails 7.0+
- Claude Code CLI

## Support

For issues and questions:

- GitHub Issues: [Create an issue]
- Documentation: See `/docs/best-practices/`
