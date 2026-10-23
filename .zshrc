# ~/.zshrc

# ── Environment ──────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
export VISUAL=nvim

typeset -U path PATH
path=(
    "$HOME/.local/lib/npm/bin"
    "$HOME/.opencode/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    $path
)

# ── Oh My Zsh ────────────────────────────────────────────────
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# ── Vi mode ──────────────────────────────────────────────────
bindkey -v

# jk → normal mode, Ctrl-R → history search
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins '^R' history-incremental-pattern-search-backward

# Text objects for quotes and brackets
autoload -Uz select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed

for m in visual viopp; do
    for c in "'" '"' '`'; do
        bindkey -M "$m" "a$c" select-quoted
        bindkey -M "$m" "i$c" select-quoted
    done

    for c in '(' ')' '[' ']' '{' '}' '<' '>'; do
        bindkey -M "$m" "a$c" select-bracketed
        bindkey -M "$m" "i$c" select-bracketed
    done
done

# Surround
autoload -Uz surround
zle -N add-surround surround
zle -N delete-surround surround
zle -N change-surround surround

bindkey -M vicmd sa add-surround
bindkey -M vicmd sd delete-surround
bindkey -M vicmd sr change-surround
bindkey -M visual S add-surround

# Cursor shape reflects vi mode
zle-keymap-select() {
    case $KEYMAP in
        vicmd) print -n '\e[2 q' ;;
        *)     print -n '\e[6 q' ;;
    esac
}

zle-line-init() {
    zle -K vicmd
    print -n '\e[2 q'
}

zle -N zle-keymap-select
zle -N zle-line-init

# System clipboard: paste before cursor, yank
paste-clipboard() {
    CUTBUFFER=$(wl-paste --no-newline) || return
    zle .vi-put-before
}

yank-clipboard() {
    zle .vi-yank
    print -rn -- "$CUTBUFFER" | wl-copy
}

zle -N paste-clipboard
zle -N yank-clipboard
bindkey -M vicmd p paste-clipboard
bindkey -M vicmd P paste-clipboard
bindkey -M vicmd y yank-clipboard

# ── Functions ────────────────────────────────────────────────
# L in normal mode: list the current directory
list-dir() {
    zle -I
    ll
    zle reset-prompt
}
zle -N list-dir
bindkey -M vicmd L list-dir
# Copy command output to clipboard
c() {
    "$@" 2>&1 | tee >(wl-copy)
}

# Run and orphan command (output goes to $BG_LOG if set, else discarded)
bg() {
    nohup "$@" >>"${BG_LOG:-/dev/null}" 2>&1 </dev/null &!
}

zathura() { bg zathura "$@" }

mousepad() { bg mousepad "$@" }

# scrcpy
typeset -ga SCRCPY_OPTS=(-Sw -m1920 --max-fps=60)

phone-on() {
    BG_LOG="$HOME/.local/state/phone.log" bg scrcpy $SCRCPY_OPTS
}

# omniroute
omniroute-on() {
    BG_LOG="$HOME/.local/state/omniroute.log" bg omniroute
}

# Convert md to pdf with pandoc
mdpdf() {
    if (( $# < 1 || $# > 2 )); then
        print -u2 "Usage: mdpdf input.md [output.pdf]"
        return 2
    fi

    local input="$1"
    local output="${2:-${1:r}.pdf}"

    pandoc "$input" \
        --pdf-engine=xelatex \
        -H "$HOME/.config/pandoc/persian-header.tex" \
        -o "$output"
}

# Tools routed through the local proxy
reels() {
    local p=socks5h://127.0.0.1:10808
    ALL_PROXY=$p HTTP_PROXY=$p HTTPS_PROXY=$p \
        command reels "$@"
}

opencode() {
    local p=http://127.0.0.1:10808
    HTTP_PROXY=$p HTTPS_PROXY=$p http_proxy=$p https_proxy=$p \
    NO_PROXY=localhost,127.0.0.1,::1 no_proxy=localhost,127.0.0.1,::1 \
        command opencode "$@"
}

# ── Aliases ──────────────────────────────────────────────────
alias vim='nvim'
alias v='nvim'
alias vimm='vim'

# prime-run
alias nvrun='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia'

# scrcpy / omniroute
alias phone='scrcpy $SCRCPY_OPTS'
alias phone-off='pkill -f "scrcpy -Sw"'
alias omniroute-off='pkill -f omniroute'

# bare git dotfiles: .zshrc .tmux.conf .config/nvim .config/kitty
alias config='git --git-dir="$HOME/.cfg" --work-tree="$HOME"'

# clipboard history
alias ch='cliphist list | fzf --no-sort --bind "j:down,k:up" | cliphist decode | wl-copy'

# ── Tools ────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Local overrides / secrets (keep out of git) ──────────────
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi
