# Repo Notes

## OPENAI_API_KEY

This repo expects `OPENAI_API_KEY` to be stored in the macOS Keychain, not in source control.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w 'your-api-key-here'
```

New `zsh` and `fish` shells load it automatically from Keychain.
