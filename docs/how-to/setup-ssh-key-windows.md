# Set Up an SSH Key on Windows

Use a normal terminal session (`cmd` or PowerShell), not an elevated administrator shell.

## 1. Generate the key

```powershell
ssh-keygen -t ed25519 -C "<email@example.com>"
```

When prompted, accept the default location:

```text
C:\Users\<username>\.ssh\id_ed25519
```

The public key will be saved here:

```text
C:\Users\<username>\.ssh\id_ed25519.pub
```

## 2. Start and configure the SSH agent

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

## 3. Display the public key

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

Copy the output to your clipboard.

## 4. Add the key to GitHub

1. Open GitHub.
2. Go to `Settings` > `SSH and GPG keys`.
3. Select `New SSH key`.
4. Enter a descriptive title, paste the public key, and save it.

## 5. Test the connection in VS Code

Open the terminal in VS Code and run:

```powershell
ssh -T git@github.com
```

The first time you connect, you may see a host authenticity prompt like this:

```text
The authenticity of host 'github.com (IP)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6Tu******dkr4UvCOqU.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Type `yes` to continue.

If everything works, GitHub should respond with a message similar to:

```text
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```
