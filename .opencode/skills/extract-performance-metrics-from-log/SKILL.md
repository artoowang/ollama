---
name: extract-performance-metrics-from-log
description: "Extract performance metrics from a given Ollama log"
version: 1.0.0
author: "Chunpo Wang"
triggers:
  - type: keyword
    patterns:
      - "Ollama performance"
---

# Extrace Performance Metrics from Ollama Log

## Workflow

1. Ask for the location of the Ollama log file. The default is /Users/ollama/log/ollama.err.log
   It is under the user ollama. Don't replace that with the current user.
1. The log file contains very long lines. Use the following command to fold those lines before parsing:
    ```shell
    fold -s -w 1000 <log_file> > <output_file>
    ```
1. Find all requests in the log. Each request should come with a group of the following messages:
    * completion request: it includes the following fields:
        * len(prompt): the number of tokens in the prompt.
        * prompt: the full prompt string.
    * loading cache slot: it includes the following fields:
        * cache_tokens: The current number of tokens in the cache (from the previous request).
        * prompt_tokens: The number of tokens in the request's prompt.
        * cache_hit_tokens: The number of tokens in the prompt that hits the cache.
        * remaining_tokens: The number of tokens in the prompt that misses the cache.
    * chat metrics: it includes the following fields:
        * prompt_eval_count: The number of tokens in the prompt.
        * prompt_eval_duration: The time spent to evalute the prompt. The better the cache hit above, the shorter the evaluation should be.
        * eval_count: The number of response tokens generated.
        * eval_duration: The time spent to generate the response tokens. eval_count / eval_duration gives us the token generation speed.
        * total_duration: The total time spent to handle this request, including prompt_eval_duration and eval_duration.
        * load_duration: The time spent to load the model. If the model is already in the memory, this should be quick.
