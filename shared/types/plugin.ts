/**
 * Core types for Claude Code plugin development
 */

export interface PluginMetadata {
  name: string;
  version: string;
  description: string;
  author: string;
  tags: string[];
  claudeCodeVersion?: string;
}

export interface CommandConfig {
  name: string;
  description: string;
  prompt: string;
  tags?: string[];
}

export interface AgentConfig {
  name: string;
  description: string;
  instructions: string;
  tools?: string[];
  examples?: AgentExample[];
}

export interface AgentExample {
  context: string;
  userMessage: string;
  assistantResponse: string;
  commentary: string;
}

export interface PluginConfig {
  metadata: PluginMetadata;
  commands?: CommandConfig[];
  agents?: AgentConfig[];
  hooks?: HookConfig[];
}

export interface HookConfig {
  event: 'pre-commit' | 'post-commit' | 'pre-push' | 'tool-call';
  script: string;
  description: string;
}

export type PluginType =
  | 'workflow'
  | 'agent'
  | 'utility'
  | 'framework-integration'
  | 'code-review';
