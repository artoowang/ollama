#!/bin/bash

set -e

SCRIPT_NAME="generate_from_prompt.sh"
DEFAULT_MODEL="qwen3.5:35b"
DEFAULT_HOST="localhost:11435"

show_usage() {
    echo "Usage: $SCRIPT_NAME -p <prompt_file> [-m <model>] [-H <host>] [-c <num_ctx>]"
    echo ""
    echo "Options:"
    echo "  -p, --prompt-file  Path to file containing the prompt text (required)"
    echo "  -m, --model        Model name (default: $DEFAULT_MODEL)"
    echo "  -H, --host         Ollama server host:port (default: $DEFAULT_HOST)"
    echo "  -c, --num-ctx      Context window size (default: server default)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME -p prompt.txt"
    echo "  $SCRIPT_NAME -p prompt.txt -m llama3.2 -H localhost:11434 -c 131072"
}

check_prerequisites() {
    if ! command -v jq &> /dev/null; then
        echo "Error: 'jq' is required but not installed."
        echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
}

parse_args() {
    PROMPT_FILE=""
    MODEL="$DEFAULT_MODEL"
    HOST="$DEFAULT_HOST"
    NUM_CTX=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--prompt-file)
                PROMPT_FILE="$2"
                shift 2
                ;;
            -m|--model)
                MODEL="$2"
                shift 2
                ;;
            -H|--host)
                HOST="$2"
                shift 2
                ;;
            -c|--num-ctx)
                NUM_CTX="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [ -z "$PROMPT_FILE" ]; then
        echo "Error: Missing required option '--prompt-file'"
        show_usage
        exit 1
    fi

    if [ ! -f "$PROMPT_FILE" ]; then
        echo "Error: Prompt file not found: $PROMPT_FILE"
        exit 1
    fi

    if [ ! -r "$PROMPT_FILE" ]; then
        echo "Error: Prompt file is not readable: $PROMPT_FILE"
        exit 1
    fi
}

main() {
    check_prerequisites
    parse_args "$@"

    local PROMPT_CONTENT
    PROMPT_CONTENT=$(cat "$PROMPT_FILE")

    curl -s -X POST "http://${HOST}/api/generate" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT_CONTENT" --arg num_ctx "$NUM_CTX" \
              '{model: $model, prompt: $prompt, stream: false, raw: true}
               + (if $num_ctx != "" then {options: {num_ctx: ($num_ctx | tonumber)}} else {} end)')"
}

main "$@"
