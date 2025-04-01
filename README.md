
# **Secure Secrets Script**

This script provides a secure and encrypted way to manage and store sensitive information, such as API keys, credentials, and other secrets. It uses GPG encryption to keep your secrets safe and allows you to easily add, retrieve, list, and delete secrets.

---

## **Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
  - [Add a Secret](#add-a-secret)
  - [Get a Secret](#get-a-secret)
  - [List All Secrets](#list-all-secrets)
  - [Delete a Secret](#delete-a-secret)
- [Best Practices](#best-practices)
- [Requirements](#requirements)
- [Security Considerations](#security-considerations)
- [License](#license)

---

## **Installation**

### **Step 1: Clone the Repository**

```bash
git clone https://github.com/pl4g4/secure-secrets.git
cd secure-secrets
```

### **Step 2: Make the Script Executable**

```bash
chmod +x secure-secrets.sh
```

### **Step 3: Ensure GPG is Installed**

The script uses GPG to encrypt and decrypt the secrets file. If GPG is not installed on your system, the script will attempt to install it.

To manually install GPG:

- **On macOS**: Use [Homebrew](https://brew.sh/):
  ```bash
  brew install gnupg
  ```

- **On Linux** (Debian/Ubuntu-based):
  ```bash
  sudo apt update && sudo apt install -y gnupg
  ```

- **On Linux** (RHEL/CentOS-based):
  ```bash
  sudo yum install -y gnupg2
  ```

---

## **Usage**

Once the script is set up, you can interact with it via the command line.

### **Add a Secret**

To add a secret, use the `add` command. You need to provide a `key` and a `value`. 

```bash
./secure-secrets.sh add <key> <value>
```

Example:

```bash
./secure-secrets.sh add dynatrace_api <your-api-token-here>
```

This will encrypt the secret and save it to the `.secrets.gpg` file.

### **Get a Secret**

To retrieve a secret, use the `get` command followed by the `key`. 

```bash
./secure-secrets.sh get <key>
```

Example:

```bash
./secure-secrets.sh get dynatrace_api
```

This will decrypt and return the value of the `dynatrace_api` secret.

### **List All Secrets**

To list all stored secrets (only keys, not values), use the `list` command:

```bash
./secure-secrets.sh list
```

### **Delete a Secret**

To delete a secret, use the `delete` command followed by the `key`:

```bash
./secure-secrets.sh delete <key>
```

Example:

```bash
./secure-secrets.sh delete dynatrace_api
```

This will remove the specified secret from the `.secrets.gpg` file.

---

## **Best Practices**

1. **Use a Strong Passphrase for GPG**: When setting up GPG, ensure that you use a strong, unique passphrase to protect your secrets.
   
2. **Encrypt Secrets File**: The `.secrets.gpg` file is the core of this script. Make sure it is securely stored in a location with proper access controls. It is highly recommended to restrict permissions (e.g., `chmod 600 ~/.secrets.gpg`).

3. **Do Not Commit Secrets**: Avoid committing your `.secrets.gpg` file to version control (e.g., Git). Use `.gitignore` to exclude it.

4. **Backup Your Secrets**: If you're using this script in production or for critical systems, ensure you have encrypted backups of your secrets.

5. **Environment Variables**: Consider storing environment variables (such as API tokens) in this encrypted file, and use them in your scripts or applications securely.

---

## **Requirements**

- **GPG**: This script relies on GPG encryption to keep your secrets secure.
- **Linux/Mac**: This script works on both Linux and macOS systems.

---

## **Security Considerations**

1. **Encrypted Secrets**: Secrets are encrypted using AES-256 encryption, ensuring that even if someone gains access to the `.secrets.gpg` file, they will not be able to read the secrets without the GPG passphrase.

2. **File Permissions**: Ensure that the `.secrets.gpg` file has restricted permissions. Use `chmod 600 ~/.secrets.gpg` to limit access to the file.

3. **Key Management**: You are responsible for managing your GPG keys securely. Store your GPG passphrase safely, and never hardcode it into scripts or code.

4. **Avoid Exposing Secrets**: Always be cautious when outputting secrets or passing them through logs, and consider masking secrets in output when running scripts.

---

### **Example Setup**: Automating API Token Retrieval

For example, if you need to retrieve a token for `dynatrace_api` and use it in a `curl` command:

```bash
curl -L -X GET "https://your-api-endpoint" -H "Authorization: Api-Token $(./secure-secrets.sh get dynatrace_api)" -H "Accept: application/json"
```

This way, you can safely use API tokens without hardcoding them directly into your scripts.

