if status is-interactive
    # Commands to run in interactive sessions can go here
end

# 檢查檔案是否存在並匯入必要的環境變數
if status is-interactive
    set -l shell_rc
    if test -f "$HOME/.bashrc"
        set shell_rc "$HOME/.bashrc"
    else if test -f "$HOME/.zshrc"
        set shell_rc "$HOME/.zshrc"
    end

    if set -q shell_rc
        # 只匯入 PATH 和必要的環境變數
        for line in (bash -c "source $shell_rc; env | grep -E '^(PATH|HOME|USER|CARGO_HOME|RUSTUP_HOME|NVM_DIR|GOPATH|GOROOT)='")
            set -l key_value (string split -m 1 '=' $line)
            set -gx $key_value[1] $key_value[2]
        end
    end
end

# 輔助函數：檢查並添加路徑，避免重複
function add_to_path
    for path in $argv
        if test -d "$path" && not contains $path $PATH
            set -gx PATH $PATH $path
        end
    end
end

# Rust/Cargo 路徑
set -gx PATH $PATH ~/.cargo/bin

# Go 路徑
if not command -v go >/dev/null; and test -d /usr/local/go/bin; and test -f /usr/local/go/bin/go
    set -gx PATH "$PATH:/usr/local/go/bin"
end
if command -v go >/dev/null
    set -q GOPATH || set -gx GOPATH (go env GOPATH)
    add_to_path "$GOPATH/bin" (go env GOROOT)/bin
end


# 添加常用路徑（確保不重複）
add_to_path /usr/local/bin /usr/bin /bin /usr/sbin /sbin
source $HOME/.env_setup
