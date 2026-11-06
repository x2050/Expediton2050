import 'package:flutter_litert_lm/flutter_litert_lm.dart';

class LocalModelService {
  LiteLmEngine? _engine;
  LiteLmConversation? _conversation;

  Future<void> load(String path) async {
    // Start on CPU for compatibility; benchmark GPU/NPU on the real handset later.
    _engine = await LiteLmEngine.create(
      LiteLmEngineConfig(
        modelPath: path,
        backend: LiteLmBackend.cpu,
      ),
    );
    _conversation = await _engine!.createConversation(
      LiteLmConversationConfig(
        systemInstruction: 'You are Aurélio, a careful documentary field assistant. '
          'Separate observed facts from inference. Do not invent cultural facts. '
          'Respect consent, attribution and restricted knowledge.',
        samplerConfig: const LiteLmSamplerConfig(
          temperature: 0.35,
          topK: 40,
          topP: 0.9,
        ),
      ),
    );
  }

  Future<String> ask(String prompt) async {
    final chat = _conversation;
    if (chat == null) throw StateError('Load a model first.');
    final result = await chat.sendMessage(prompt);
    return result.text;
  }

  Future<void> close() async {
    // Release native memory before loading a different model.
    await _conversation?.dispose();
    await _engine?.dispose();
    _conversation = null;
    _engine = null;
  }
}
