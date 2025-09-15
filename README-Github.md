Github
=====

To create an SSH key for GitHub, you can follow these steps:

### 1\. Check for Existing Keys

First, check if you already have an SSH key on your system. Open a terminal (Git Bash on Windows, Terminal on
macOS/Linux) and run the following command:

```bash
ls -al ~/.ssh
```

If you see files named `id_rsa.pub` or `id_ecdsa.pub`, you already have a key. If you don't want to overwrite it, you
can skip the next step.

-----

### 2\. Generate a New SSH Key

To generate a new SSH key, use the following command. Replace `"your_email@example.com"` with your GitHub email address.
The `-t ed25519` flag creates a new key using a modern, secure algorithm.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted to "Enter a file in which to save the key," you can press **Enter** to accept the default location.

Next, you'll be asked to "Enter passphrase." It's highly recommended to **create a strong passphrase** for added
security. This passphrase will be required every time you use the SSH key. If you don't want a passphrase, you can press
**Enter** twice to leave it blank, but this is less secure.

-----

### 3\. Start the SSH Agent

The **SSH agent** manages your SSH keys and remembers your passphrase so you don't have to enter it every time you
connect. Start the agent in the background with this command:

```bash
eval "$(ssh-agent -s)"
```

-----

### 4\. Add Your SSH Key to the Agent

Now, add your newly created SSH key to the SSH agent. Use the following command. If you saved your key with a different
filename, be sure to use that instead of `id_ed25519`.

```bash
ssh-add ~/.ssh/id_ed25519
```

You'll be prompted to enter the passphrase you created in step 2.

-----

### 5\. Copy the SSH Key to Your Clipboard

To add the key to GitHub, you need to copy its content to your clipboard.

* **macOS:** `pbcopy < ~/.ssh/id_ed25519.pub`
* **Linux:** `xclip -sel clip < ~/.ssh/id_ed25519.pub` (you may need to install `xclip`)
* **Git Bash on Windows:** `clip < ~/.ssh/id_ed25519.pub`

-----

### 6\. Add the SSH Key to Your GitHub Account

Finally, add the copied key to your GitHub account.

1. Go to **GitHub** and click on your profile picture in the top-right corner.
2. Select **Settings**.
3. In the left sidebar, click **SSH and GPG keys**.
4. Click the **New SSH key** button.
5. In the "Title" field, give your key a descriptive name (e.g., "My Laptop").
6. Paste the key you copied in the "Key" field.
7. Click **Add SSH key**. You may be asked to enter your GitHub password to confirm.

-----

### 7\. Test the Connection

To verify that everything is set up correctly, open your terminal and run the following command:

```bash
ssh -T git@github.com
```

You will see a message like "Hi *username*\! You've successfully authenticated...". This confirms your SSH key is
working.

# Reference

[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
