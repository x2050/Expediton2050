class ModelChoice {
  const ModelChoice({
    required this.id,
    required this.name,
    required this.repo,
    required this.file,
    required this.minimumBytes,
    required this.role,
  });

  final String id;
  final String name;
  final String repo;
  final String file;
  final int minimumBytes;
  final String role;

  // Hugging Face hosts the weights; inference remains entirely on the phone.
  String get url => 'https://huggingface.co/$repo/resolve/main/$file';
}

class ModelCatalog {
  static const choices = <ModelChoice>[
    ModelChoice(
      id: 'gemma4-e2b',
      name: 'Gemma 4 E2B',
      repo: 'litert-community/gemma-4-E2B-it-litert-lm',
      file: 'gemma-4-E2B-it.litertlm',
      minimumBytes: 1800000000,
      role: 'Recommended default',
    ),
    ModelChoice(
      id: 'gemma4-e4b',
      name: 'Gemma 4 E4B',
      repo: 'litert-community/gemma-4-E4B-it-litert-lm',
      file: 'gemma-4-E4B-it.litertlm',
      minimumBytes: 2800000000,
      role: 'Higher capability; more memory pressure',
    ),
    ModelChoice(
      id: 'qwen3-06b',
      name: 'Qwen3 0.6B',
      repo: 'litert-community/Qwen3-0.6B',
      file: 'Qwen3-0.6B.litertlm',
      minimumBytes: 400000000,
      role: 'Lightweight fallback',
    ),
  ];
}
