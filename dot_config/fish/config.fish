# Fish Shell Configuration
# ~/.config/fish/config.fish

# ============================================================================
# PATH
# ============================================================================

fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

# ============================================================================
# VI MODE & KEY BINDINGS
# ============================================================================

# Enable vi key bindings
fish_vi_key_bindings

# Custom key bindings
function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cf forward-char
        bind -M $mode \ef forward-word
    end
end

# Cursor shape configuration
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
set fish_cursor_external line
set fish_cursor_visual block

# ============================================================================
# THEME
# ============================================================================

# Pure prompt colors (if using pure theme)
set --universal pure_color_primary 18CAE6
set --universal pure_color_success A220EA

# Theme date format
set -g theme_date_format "+ %H:%M"

# ============================================================================
# ALIASES
# ============================================================================

# Zellij
alias zl="zellij --layout ~/.config/zellij/layouts/wide.kdl"
alias zz="zi"

# Git shortcuts
alias ga="git add ."
alias gc="git commit"
alias gpu="git push"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"

# Utilities
alias mvall="find . -mindepth 2 -type f -exec mv -i '{}' . ';'"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'

# Modern replacements
alias y="yazi"

# List variations
alias ll="ls -l"
alias la="ls -lah"

# Modern CLI tools (if installed)
if command -v eza > /dev/null
    alias ls="eza --icons"
    alias ll="eza --icons -l"
    alias la="eza --icons -la"
end

if command -v bat > /dev/null
    alias cat="bat"
end

if command -v btm > /dev/null
    alias top="btm"
end

# Safety nets
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# Chezmoi shortcuts
alias cz="chezmoi"
alias cup="chezmoi update"        # Pull and apply changes
alias czd="chezmoi diff"          # See what would change
alias cza="chezmoi apply -v"      # Apply changes
alias cze="chezmoi edit"          # Edit a managed file
alias czs="chezmoi status"        # Check status

# Claude shortcuts
alias c="claude"
alias cdang="claude --permission-mode bypassPermissions"
alias ccr="claude --resume --model opusplan --effort auto"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Quick directory creation and navigation
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

# Extract various archive types
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Quick find
function f
    find . -name "*$argv[1]*"
end

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================

# Starship prompt
if command -v starship > /dev/null
    starship init fish | source
end

# Zoxide (smart cd)
if command -v zoxide > /dev/null
    zoxide init fish | source
end

# Atuin (shell history)
if command -v atuin > /dev/null
    atuin init fish | source
end

# ============================================================================
# ENVIRONMENT-SPECIFIC SETTINGS
# ============================================================================

# Load local customizations if they exist
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

# Moshi iOS client signal: app Settings -> Integrations -> Export ENV.
# Reserved for prompt/glyph trims when running under Moshi. Starship handles
# the prompt here, so leave this branch empty unless you add tweaks.
if set -q MOSHI_CLIENT
    # extension point — e.g. set -gx STARSHIP_CONFIG ~/.config/starship-moshi.toml
end

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Load OpenAI API key from the macOS Keychain.
# Universal expectation — warn loudly so a missing entry doesn't surface as a
# confusing tool error hours later. Suppress with NO_KEYCHAIN_WARNINGS=1.
if not set -q OPENAI_API_KEY
    if test -x /usr/bin/security
        set openai_api_key (/usr/bin/security find-generic-password -a "$USER" -s OPENAI_API_KEY -w 2>/dev/null)
    end

    if test -n "$openai_api_key"
        set -gx OPENAI_API_KEY $openai_api_key
    else if not set -q NO_KEYCHAIN_WARNINGS
        echo "warn: keychain entry 'OPENAI_API_KEY' not found; OPENAI_API_KEY unset" >&2
    end
end

# Load GitHub PAT for Codex from the macOS Keychain.
if not set -q GITHUB_PAT_TOKEN
    if test -x /usr/bin/security
        set github_pat_token (/usr/bin/security find-generic-password -a "$USER" -s codex-github-pat -w 2>/dev/null)
    end

    if test -n "$github_pat_token"
        set -gx GITHUB_PAT_TOKEN $github_pat_token
    else if not set -q NO_KEYCHAIN_WARNINGS
        echo "warn: keychain entry 'codex-github-pat' not found; GITHUB_PAT_TOKEN unset" >&2
    end
end

# Load the work-only Logseq DB MCP token from the macOS Keychain.
if not set -q LOGSEQ_DB_MCP_TOKEN
    if test -x /usr/bin/security
        set logseq_db_mcp_token (/usr/bin/security find-generic-password -a "$USER" -s logseq-db-mcp-token -w 2>/dev/null)
    end

    if test -n "$logseq_db_mcp_token"
        set -gx LOGSEQ_DB_MCP_TOKEN $logseq_db_mcp_token
    end
end

set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx EDITOR nvim
set -gx VISUAL nvim
