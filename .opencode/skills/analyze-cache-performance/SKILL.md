---
name: analyze-cache-performance
description: "Analyze the cache performance in a given Ollama log"
version: 1.0.0
author: "Chunpo Wang"
triggers:
  - type: keyword
    patterns:
      - "Ollama cache performance"
---

# Analyze Cache Performance

## Workflow

1. Ask for the location of the Ollama log file. The default is /tmp/log.
1. The log file contains very long lines. Use the following command to fold those lines before parsing:
    ```shell
    fold -s -w 1000 <log_file> > <output_file>
    ```
1. Find the recent "completion request" in the log. Ask which request to analyze.
1. The cache performance is affected by the previous request, so given a "completion request" to analyze, we calso need to look at the request before it.
1. There shouuld be one "loading cache slot" immediately after each request, which shows the cache performance of the said request. It shows 4 metrics:
    * cache_tokens: The current number of tokens in the cache (from the previous request).
    * prompt_tokens: The number of tokens in the request's prompt.
    * cache_hit_tokens: The number of tokens in the prompt that hits the cache.
    * remaining_tokens: The number of tokens in the prompt that misses the cache.
1. The cache_hit_tokens should be high, and remaining_tokens should be low. If that is not the case, compare the "prompt" strings in both requests, and see where the strings start to differ.
