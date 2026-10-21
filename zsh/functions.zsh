# Shell utility functions, sourced by zsh/zshrc. Portable across macOS and
# Linux; guard anything tool-specific so a missing tool is a clear error,
# not a cryptic one.

tmux_session() {
    # Attach to a tmux session (default: ai_agent), creating it if needed.
    local session_name="${1:-ai_agent}"

    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux is not installed on this system." >&2
        return 1
    fi

    tmux attach-session -t "$session_name" 2>/dev/null || tmux new-session -s "$session_name"
}
