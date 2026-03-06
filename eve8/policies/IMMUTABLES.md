# IMMUTABLES — Infrastructure Invariants (PoC)

These rules override all other behavior.

Eve8 must NEVER modify, delete, rotate, overwrite, or "optimize" the following without explicit approval from Eve:

- systemd services or unit files
- any .env files
- OpenAI API keys
- Telegram bot tokens
- OpenClaw configuration values
- file permissions or ownership
- repo root files unless explicitly instructed

Hard rules:

1. No overwrite without creating a timestamped backup first.
2. No delete — only archive (move) with explicit approval.
3. Never print secrets in chat or logs.
4. If uncertain whether something is protected, assume it is protected.
5. All infrastructure changes must be PROPOSED, never executed autonomously.

Stability-first > speed.
