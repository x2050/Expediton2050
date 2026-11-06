# 04 — Local AI Model Guide

## 1. Purpose

Run supported language models locally on the Samsung Galaxy S25 Ultra using a compatible LiteRT-LM runtime. Local inference can support summarization, field-note organization and draft research assistance without sending prompt content to a remote AI service.

## 2. Model selection

Candidate model catalogue from the project plan:

| Model | Intended role | Approximate file size* |
|---|---|---:|
| Gemma 4 E2B LiteRT-LM | Default local assistant | ~2.46 GB |
| Gemma 4 E4B LiteRT-LM | Higher-capability optional model | ~3.40 GB |
| Qwen3 0.6B LiteRT-LM | Lightweight fallback | ~586 MB |

*Approximate sizes from the project research notes; confirm the current model card and actual download before provisioning storage. Model availability, licensing, file names and runtime compatibility can change.

Candidate repositories/files to verify against their current model cards:
- `litert-community/gemma-4-E2B-it-litert-lm`
- `gemma-4-E2B-it.litertlm`
- `litert-community/gemma-4-E4B-it-litert-lm`
- `gemma-4-E4B-it.litertlm`
- `litert-community/Qwen3-0.6B`
- `Qwen3-0.6B.litertlm`

Do not assume a model is compatible just because its name contains Gemma, Qwen or LiteRT. Confirm exact format and runtime support.

## 3. Storage planning

Reserve space for:
- model file;
- temporary partial download;
- application database and media;
- Android cache;
- exported backups.

A download can temporarily require more space than the final model size. Check available storage before starting.

## 4. Download workflow

1. Use a trusted source and verify the exact repository and filename.
2. Show the model licence and source to the user.
3. Download to app-private storage.
4. Write to a temporary `.part` file.
5. Report progress and support cancellation.
6. Verify file size and checksum if a trusted checksum is published.
7. Rename to the final filename only after verification.
8. Keep the previous working model until the new model passes a smoke test.

Never download executable code or model files from arbitrary links suggested by an untrusted prompt.

## 5. Load and test

1. Confirm model file exists and is readable.
2. Confirm runtime supports the model format and device.
3. Initialize the engine.
4. Create a conversation with a short system instruction.
5. Send a short test prompt.
6. Display the response.
7. Dispose of conversation and engine resources when finished.

Example smoke-test prompt:
> Reply with the phrase “Expedition offline test passed” and then list three things you should verify before summarizing an interview.

## 6. Prompt template for field research

Use a careful system instruction:
> You are a documentary research assistant. Preserve the speaker's meaning. Do not invent facts, names, dates or quotations. Distinguish source statements from your interpretation. Mark uncertainty explicitly. Respect consent and restrictions attached to the source material.

## 7. Summarization workflow

Input:
- transcript or field notes;
- source ID;
- language;
- known spelling of names/places;
- consent and usage restrictions.

Output:
- neutral summary;
- key themes;
- direct quotations only when verified against the source;
- names and terms requiring verification;
- unanswered questions;
- confidence/uncertainty notes.

Always retain the original transcript or recording. AI summaries are derivative records, not replacements.

## 8. Model switching

Before switching:
- save the current conversation;
- stop active generation;
- dispose of the current conversation and engine;
- release references to the old model;
- initialize the new model;
- run a smoke test.

If Android kills the app or reports memory pressure, reduce context length, use a smaller model, close other applications or restart the app. Do not promise that every model will fit or run at a particular speed.

## 9. Privacy and network behavior

Local inference does not automatically mean the entire workflow is offline. Model downloads, web research, remote transcription, cloud backups and analytics may use the network. Clearly label each feature as local or online. Provide an offline test mode and do not silently upload field recordings.

## 10. Performance log

For each device/model test, record:
- phone model and Android version;
- runtime/plugin version;
- model repository, filename and checksum;
- model file size;
- load time;
- prompt length and response time;
- memory/thermal observations;
- whether airplane-mode inference passed;
- date and app commit.

## 11. Acceptance tests

- [ ] Model source and licence verified.
- [ ] Download can be cancelled.
- [ ] Interrupted download does not appear as installed.
- [ ] Corrupt file is rejected.
- [ ] Model loads and answers a smoke test.
- [ ] Model works in airplane mode after download.
- [ ] Engine can be disposed and reloaded.
- [ ] App remains usable when model load fails.
