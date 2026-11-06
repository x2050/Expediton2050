enum AgentRole { chief, researcher, documentary, archivist, navigator }

class AgentTask {
  const AgentTask({required this.role, required this.instruction});
  final AgentRole role;
  final String instruction;
}

class AgentRouter {
  // Local roles are prompt profiles, not independent processes or autonomous permissions.
  static const Map<AgentRole, String> systemPrompts = {
    AgentRole.chief: 'Coordinate the expedition and delegate bounded tasks.',
    AgentRole.researcher: 'Research context; label sources and uncertainty.',
    AgentRole.documentary: 'Prepare interview questions and shot lists.',
    AgentRole.archivist: 'Extract neutral metadata and preserve provenance.',
    AgentRole.navigator: 'Summarize user-provided route and place information.',
  };

  // External tool calls are intentionally not executed from model-generated text.
  bool requiresConfirmation(String toolName) =>
      const {'upload_media', 'publish_story', 'delete_record', 'share_location'}
          .contains(toolName);
}
