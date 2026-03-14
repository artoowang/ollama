#!/bin/bash

set -e

SCRIPT_NAME="generate_from_prompt.sh"
DEFAULT_MODEL="qwen3.5:35b"
DEFAULT_HOST="localhost:11435"

show_usage() {
    echo "Usage: $SCRIPT_NAME <prompt_file> [model] [host]"
    echo ""
    echo "Arguments:"
    echo "  prompt_file  Path to file containing the prompt text (required)"
    echo "  model        Model name (default: $DEFAULT_MODEL)"
    echo "  host         Ollama server host:port (default: $DEFAULT_HOST)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME prompt.txt"
    echo "  $SCRIPT_NAME prompt.txt llama3.2 localhost:11434"
}

check_prerequisites() {
    if ! command -v jq &> /dev/null; then
        echo "Error: 'jq' is required but not installed."
        echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
}

validate_args() {
    if [ $# -lt 1 ]; then
        echo "Error: Missing required argument 'prompt_file'"
        show_usage
        exit 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: Prompt file not found: $1"
        exit 1
    fi

    if [ ! -r "$1" ]; then
        echo "Error: Prompt file is not readable: $1"
        exit 1
    fi
}

main() {
    check_prerequisites
    validate_args "$@"

    local PROMPT_FILE="$1"
    local MODEL="${2:-$DEFAULT_MODEL}"
    local HOST="${3:-$DEFAULT_HOST}"

    local PROMPT_CONTENT
    PROMPT_CONTENT=$(cat "$PROMPT_FILE")

    curl -s -X POST "http://${HOST}/api/generate" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT_CONTENT" \
              '{model: $model, prompt: $prompt, stream: false}')"
}

main "$@"
