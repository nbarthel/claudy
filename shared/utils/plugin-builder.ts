import { PluginConfig, CommandConfig, AgentConfig } from '../types/plugin';

/**
 * Utility class for building Claude Code plugins
 */
export class PluginBuilder {
  private config: Partial<PluginConfig> = {};

  withMetadata(metadata: PluginConfig['metadata']): this {
    this.config.metadata = metadata;
    return this;
  }

  addCommand(command: CommandConfig): this {
    if (!this.config.commands) {
      this.config.commands = [];
    }
    this.config.commands.push(command);
    return this;
  }

  addAgent(agent: AgentConfig): this {
    if (!this.config.agents) {
      this.config.agents = [];
    }
    this.config.agents.push(agent);
    return this;
  }

  build(): PluginConfig {
    if (!this.config.metadata) {
      throw new Error('Plugin metadata is required');
    }
    return this.config as PluginConfig;
  }

  /**
   * Generate .claude/commands directory structure
   */
  generateCommandFiles(): Map<string, string> {
    const files = new Map<string, string>();

    if (this.config.commands) {
      for (const command of this.config.commands) {
        const filename = `.claude/commands/${command.name}.md`;
        files.set(filename, this.generateCommandContent(command));
      }
    }

    return files;
  }

  /**
   * Generate .claude/agents directory structure
   */
  generateAgentFiles(): Map<string, string> {
    const files = new Map<string, string>();

    if (this.config.agents) {
      for (const agent of this.config.agents) {
        const filename = `.claude/agents/${agent.name}.md`;
        files.set(filename, this.generateAgentContent(agent));
      }
    }

    return files;
  }

  private generateCommandContent(command: CommandConfig): string {
    let content = `# ${command.name}\n\n`;
    content += `${command.description}\n\n`;
    content += `---\n\n`;
    content += `${command.prompt}\n`;
    return content;
  }

  private generateAgentContent(agent: AgentConfig): string {
    let content = `# ${agent.name}\n\n`;
    content += `${agent.description}\n\n`;
    content += `## Instructions\n\n`;
    content += `${agent.instructions}\n\n`;

    if (agent.tools && agent.tools.length > 0) {
      content += `## Available Tools\n\n`;
      content += agent.tools.map(tool => `- ${tool}`).join('\n');
      content += '\n\n';
    }

    if (agent.examples && agent.examples.length > 0) {
      content += `## Examples\n\n`;
      for (const example of agent.examples) {
        content += `<example>\n`;
        content += `Context: ${example.context}\n`;
        content += `user: "${example.userMessage}"\n`;
        content += `assistant: "${example.assistantResponse}"\n`;
        content += `<commentary>\n${example.commentary}\n</commentary>\n`;
        content += `</example>\n\n`;
      }
    }

    return content;
  }
}
