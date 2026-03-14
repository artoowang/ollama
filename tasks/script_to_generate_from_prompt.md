# Goal

Create a script to send generate API to Ollama, with prompt from a given file.

## The generate API

curl http://localhost:11435/api/generate -d '{
  "model": "qwen3.5:35b",
  "prompt": "<prompt_content>",
  "stream": false
}'

where the "<prompt_content>" is from a given file. Proper encoding should be done accordingly, so it does not corrupt the JSON.

## Implementation Plan

### Location
- `/Users/artoowang/Programs/ollama/scripts/generate_from_prompt.sh`

### Features

1. **Arguments**
   - Required: `prompt_file` - Path to file containing the prompt text
   - Optional: `model` - Model name (default: `qwen3.5:35b`)
   - Optional: `host` - Ollama server host:port (default: `localhost:11435`)

2. **Implementation**
   - Use `jq -n --arg` for safe JSON encoding of prompt content
   - Read entire file content and pass to jq as argument
   - Send POST request to `/api/generate` endpoint
   - Set `stream: false` for non-streaming response

3. **Error Handling**
   - Check if `jq` is installed
   - Verify prompt file exists and is readable
   - Validate required arguments

### Usage Examples

```bash
./scripts/generate_from_prompt.sh prompt.txt
./scripts/generate_from_prompt.sh prompt.txt llama3.2 localhost:11434
```

### Command Structure

```bash
curl -s -X POST "http://${HOST}/api/generate" \
  -H "Content-Type: application/json" \
  -d $(jq -n --arg model "$MODEL" --arg prompt "$(cat "$PROMPT_FILE")" \
        '{model: $model, prompt: $prompt, stream: false}')
```
