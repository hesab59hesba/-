# Custom Aliases
alias desktop='~/start-desktop.sh'
alias ollamaserver="ollama serve &"

# Ollama Environment Setup
export OLLAMA_HOST=127.0.0.1:11434

# Start SSH Server
sshd

# --- Claude Code & OpenRouter Integration ---

# 1. OpenRouter API Key (Populating this bypasses the login screen)
export ANTHROPIC_API_KEY="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"

# 2. Base URL for OpenRouter API Endpoint
export ANTHROPIC_BASE_URL="https://openrouter.ai/api"

# 3. Model Routing Overrides (Force Claude Code to use your chosen model)
export ANTHROPIC_DEFAULT_HAIKU_MODEL="inclusionai/ling-3.0-flash:free"
export ANTHROPIC_DEFAULT_SONNET_MODEL="inclusionai/ling-3.0-flash:free"
export ANTHROPIC_DEFAULT_OPUS_MODEL="dots-studio/dots-3-note-preview:free"
export ANTHROPIC_MODEL="dots-studio/dots-3-note-preview:free"

# 4. Turn off Gateway Discovery
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=0

# 5. Explicitly UNSET conflicting variables
unset ANTHROPIC_AUTH_TOKEN

export PATH=$HOME/bin:$PATH
alias desktop3=~/bin/desktop3
alias desktop4=~/bin/desktop4
