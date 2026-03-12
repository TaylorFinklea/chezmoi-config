# Repo Notes

## OPENAI_API_KEY

Store `OPENAI_API_KEY` in the macOS Keychain instead of this repo.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w 'your-api-key-here'
```

Open a new `zsh` or `fish` shell after saving it so the variable is exported automatically.
