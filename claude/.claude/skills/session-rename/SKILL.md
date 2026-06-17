---
name: session-rename
description: Rename the current Claude Code session based on conversation context, including the Jira ticket number if available.
---

Rename the current session to a short, descriptive title that reflects what this session is actually about.

## Steps

1. Scan the conversation context for:
   - A Jira ticket number (pattern `KAN-\d+`) — from the ticket URL, PR title, branch name, or any mention
   - The core topic: what problem is being solved or what feature is being built

2. Compose the session name:
   - Format: `KAN-XXXX <short description>` if a ticket number is found
   - Format: `<short description>` if no ticket number is present
   - Max ~60 characters
   - Use title case or sentence case — no trailing punctuation
   - Be specific: "Prevent duplicate RFI guard KYB + KYC" not "Fix bug"

3. Copy the rename command to clipboard using Bash:
   ```
   echo -n "/rename <composed name>" | pbcopy
   ```

4. Output the rename command as plain text with no leading bullet or symbol and tell the user it has been copied to clipboard:
   ```
   /rename <composed name>
   ```
   Claude cannot execute `/rename` directly — it is a UI command. Just print it.

## Rules

- Ticket number always leads if present
- Description should match what actually happened in the session, not just the ticket title — if the scope expanded (e.g. started as KYB-only, ended up covering KYC too), reflect the actual scope
- Never use generic names like "Coding session" or "Feature work"
- If multiple tickets were touched, use the primary one
