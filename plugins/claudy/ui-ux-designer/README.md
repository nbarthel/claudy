# UI/UX Design Agent Plugin

A specialized Claude Code agent for iterative UI/UX design and refinement. This agent helps create, review, and polish user interfaces through collaborative feedback loops and visual design expertise.

## Installation

1. Copy the `.claude` directory to your project root:

```bash
cp -r plugins/ui-ux-design-agent/.claude /path/to/your/project/
```

2. The agent will automatically be available for use in Claude Code

## Usage

The UI/UX designer agent can be invoked for various design tasks:

### Design Creation

```
"I need to design a dashboard for analytics"
"Create a modern login form with good UX"
"Design a card component for blog posts"
"Help me design a responsive navigation menu"
```

### Design Refinement

```
"This layout doesn't feel right, can you improve it?"
"The spacing feels off, can you adjust it?"
"Make this more accessible"
"Improve the visual hierarchy of this page"
```

### Iterative Feedback

```
"Here's a screenshot of my current design, what do you think?"
"The colors don't work well together"
"Can you try a different layout approach?"
"I like it but it needs more polish"
```

## What the Agent Does

### Visual Design

- Creates component layouts
- Applies design principles
- Implements color schemes
- Optimizes typography
- Establishes visual hierarchy
- Designs spacing systems

### User Experience

- Optimizes user flows
- Improves interaction patterns
- Enhances usability
- Designs intuitive navigation
- Implements feedback mechanisms
- Reduces cognitive load

### Accessibility

- Ensures WCAG compliance
- Designs for screen readers
- Implements keyboard navigation
- Provides color contrast
- Creates inclusive experiences
- Considers diverse abilities

### Responsive Design

- Mobile-first approach
- Breakpoint strategies
- Fluid typography
- Flexible layouts
- Touch target sizing
- Cross-device consistency

### Iterative Refinement

- Gathers visual feedback
- Implements changes quickly
- Tests variations
- Progressive enhancement
- Performance optimization
- Visual regression prevention

## The Iterative Design Process

1. **Understanding**
   - Clarify design goals
   - Understand user needs
   - Review constraints
   - Define success metrics

2. **Initial Design**
   - Create first version
   - Apply design principles
   - Implement responsiveness
   - Follow design system

3. **Feedback Loop**
   - Present for review
   - Gather specific feedback
   - Ask clarifying questions
   - Identify improvements

4. **Iteration**
   - Implement feedback
   - Refine visual elements
   - Test improvements
   - Validate changes

5. **Validation**
   - Review requirements
   - Test accessibility
   - Verify responsiveness
   - Confirm satisfaction

## Design Principles

The agent applies these core principles:

1. **Clarity** - Clear visual hierarchy and purpose
2. **Consistency** - Follow established patterns
3. **Simplicity** - Remove unnecessary complexity
4. **Feedback** - Provide clear user feedback
5. **Efficiency** - Minimize user effort
6. **Forgiveness** - Allow undo and recovery
7. **Accessibility** - Design for all users
8. **Delight** - Add thoughtful touches

## Features

### Layout & Structure

- Grid systems (Flexbox, CSS Grid)
- Component composition
- Spacing systems
- Container queries
- Semantic HTML

### Typography

- Font selection and pairing
- Type scale systems
- Line height optimization
- Readability enhancements
- Responsive typography

### Color Design

- Color palette creation
- Contrast ratio compliance
- Semantic color systems
- Dark mode support
- Accessibility validation

### Component Design

- Buttons and inputs
- Navigation patterns
- Card layouts
- Modal dialogs
- Loading states
- Error states

### Interactions

- Hover states
- Focus indicators
- Click feedback
- Smooth transitions
- Micro-animations
- Gesture support

## Example Workflows

### Creating a Dashboard

```
User: "I need to design a dashboard for displaying user metrics"

Agent:
1. Asks about key metrics to display
2. Creates initial layout with card-based design
3. Implements responsive grid
4. Adds data visualization components
5. Requests feedback
6. Iterates based on feedback
7. Polishes final design
```

### Improving Existing Design

```
User: "Here's my current form (screenshot). It doesn't feel right."

Agent:
1. Analyzes the screenshot
2. Identifies issues (spacing, hierarchy, etc.)
3. Suggests specific improvements
4. Implements changes
5. Presents refined version
6. Gathers feedback
7. Makes final adjustments
```

### Responsive Navigation

```
User: "My navigation doesn't work on mobile"

Agent:
1. Reviews current navigation
2. Proposes mobile-friendly pattern
3. Implements hamburger menu
4. Adds smooth transitions
5. Tests across breakpoints
6. Validates touch targets
7. Ensures accessibility
```

## Common Design Patterns

The agent knows and applies:

- **Card Pattern** - Grouping related information
- **Hero Pattern** - Prominent messaging
- **Dashboard Pattern** - Data visualization
- **Form Pattern** - Data collection
- **List Pattern** - Displaying items
- **Modal Pattern** - Focused tasks
- **Navigation Pattern** - Site structure
- **Empty State Pattern** - No-data scenarios

## Design Checklist

The agent validates:

- [ ] Visual hierarchy is clear
- [ ] Spacing is consistent
- [ ] Colors meet contrast ratios
- [ ] Typography is readable
- [ ] Interactive elements are obvious
- [ ] Responsive across breakpoints
- [ ] Accessible with keyboard
- [ ] Loading states included
- [ ] Error states handled
- [ ] Animations are smooth
- [ ] Performance is acceptable
- [ ] Design system followed

## Technologies

Works with:

- HTML5 semantic elements
- Modern CSS (Grid, Flexbox, Custom Properties)
- Tailwind CSS / CSS-in-JS
- React / Vue / other frameworks
- Design systems (Material, Ant Design, etc.)
- Accessibility tools (ARIA, WCAG)

## Integration with Screenshots

The agent can:

- Analyze provided screenshots
- Compare before/after designs
- Implement designs from mockups
- Generate visual variations
- Provide visual feedback

## Best Practices Enforced

1. **Mobile-First Design**: Start with mobile, enhance for desktop
2. **Accessibility First**: WCAG compliance by default
3. **Performance**: Optimize images and animations
4. **Consistency**: Follow design system
5. **User-Centered**: Focus on user needs
6. **Iterative**: Embrace feedback and refinement

## Requirements

- Modern browser support
- CSS3 capabilities
- Responsive viewport
- Claude Code CLI

## Contributing

To improve the agent:

1. Add new design patterns
2. Include more examples
3. Enhance accessibility checks
4. Add design system integrations

## License

MIT License - see LICENSE file

## Version

0.1.0 - Initial release

## Support

For issues and questions:

- GitHub Issues: [Create an issue]
- Documentation: See `/docs/best-practices/`

## Examples Directory

See the `examples/` directory for:

- Dashboard designs
- Form layouts
- Navigation patterns
- Component libraries
- Responsive layouts
- Accessibility examples
