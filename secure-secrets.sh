#!/bin/bash

SECRETS_FILE="$HOME/.secrets.gpg"
TEMP_FILE="$HOME/.secrets.tmp"
PASSPHRASE_FILE="$HOME/.secrets.pass"

# Create passphrase file if it doesn't exist
init_passphrase() {
    if [[ ! -f "$PASSPHRASE_FILE" ]]; then
        echo "🔐 First time setup: Creating encryption passphrase..."
        read -s -p "Enter a strong passphrase: " passphrase
        echo
        echo "$passphrase" > "$PASSPHRASE_FILE"
        chmod 600 "$PASSPHRASE_FILE"
    fi
}

# 🛠 Check if GPG is Installed (Mac & Linux)
check_gpg() {
    if ! command -v gpg &>/dev/null; then
        echo "⚠️  GPG is not installed. Installing now..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &>/dev/null; then
                brew install gnupg
            else
                echo "❌ Homebrew not found. Install GPG manually: https://gnupg.org/download/"
                exit 1
            fi
        elif [[ -f "/etc/debian_version" ]]; then
            sudo apt update && sudo apt install -y gnupg
        elif [[ -f "/etc/redhat-release" ]]; then
            sudo yum install -y gnupg2
        else
            echo "❌ Unsupported OS. Install GPG manually: https://gnupg.org/download/"
            exit 1
        fi
    fi
}

# 🔒 Encrypt the Secrets File
encrypt_secrets() {
    if [[ -f "$PASSPHRASE_FILE" ]]; then
        gpg --batch --yes --passphrase-file "$PASSPHRASE_FILE" --symmetric --cipher-algo AES256 --output "$SECRETS_FILE" "$TEMP_FILE"
        chmod 600 "$SECRETS_FILE"
        rm -f "$TEMP_FILE"
    else
        echo "❌ Error: Passphrase file not found. Run initialization first."
        exit 1
    fi
}

# 🔓 Decrypt and Read Secrets
decrypt_secrets() {
    if [[ -f "$SECRETS_FILE" ]]; then
        if [[ -f "$PASSPHRASE_FILE" ]]; then
            gpg --batch --quiet --passphrase-file "$PASSPHRASE_FILE" --decrypt "$SECRETS_FILE" 2>/dev/null || echo ""
        else
            echo "❌ Error: Passphrase file not found. Run initialization first."
            exit 1
        fi
    else
        echo ""
    fi
}

# ➕ Add or Update a Secret
add_secret() {
    local key="$1"
    local value="$2"

    if [[ -z "$key" || -z "$value" ]]; then
        echo "❌ Error: Provide both a key and a value."
        exit 1
    fi

    decrypt_secrets > "$TEMP_FILE" 2>/dev/null || touch "$TEMP_FILE"

    if grep -q "^$key=" "$TEMP_FILE"; then
        sed -i.bak "s|^$key=.*|$key=$value|" "$TEMP_FILE" && rm -f "$TEMP_FILE.bak"
        echo "✅ Secret '$key' updated."
    else
        echo "$key=$value" >> "$TEMP_FILE"
        echo "✅ Secret '$key' added."
    fi

    encrypt_secrets
}

# 🔍 Retrieve a Secret
get_secret() {
    local key="$1"

    if [[ -z "$key" ]]; then
        echo "❌ Error: Provide a key to retrieve."
        exit 1
    fi

    decrypt_secrets | grep "^$key=" | cut -d '=' -f2 || echo "❌ Key '$key' not found."
}

# 📜 List All Stored Secrets
list_secrets() {
    decrypt_secrets | cut -d '=' -f1 || echo "🔒 No secrets stored."
}

# 🗑 Delete a Specific Secret
delete_secret() {
    local key="$1"

    if [[ -z "$key" ]]; then
        echo "❌ Error: Provide a key to delete."
        exit 1
    fi

    decrypt_secrets > "$TEMP_FILE" 2>/dev/null || { echo "❌ No secrets stored."; exit 1; }

    if grep -q "^$key=" "$TEMP_FILE"; then
        grep -v "^$key=" "$TEMP_FILE" > "${TEMP_FILE}.new" && mv "${TEMP_FILE}.new" "$TEMP_FILE"
        encrypt_secrets
        echo "🗑 Secret '$key' deleted."
    else
        echo "❌ Key '$key' not found."
    fi
}

# 📌 Usage Instructions
usage() {
    echo "Usage: $0 {add|get|list|delete} [key] [value]"
}

# 🔄 Ensure GPG is Installed and Passphrase is Set Before Running Any Command
check_gpg
init_passphrase

case "$1" in
    add)
        add_secret "$2" "$3"
        ;;
    get)
        get_secret "$2"
        ;;
    list)
        list_secrets
        ;;
    delete)
        delete_secret "$2"
        ;;
    *)
        usage
        exit 1
        ;;
esac
