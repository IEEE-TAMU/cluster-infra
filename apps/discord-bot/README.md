# Discord Bot

This Discord bot listens to messages in the specified channel and re-posts everything from that channel through a GroupMe bot to an associated GroupMe group.

It also exposes the lounge music slash commands. Those commands are disabled unless `MUSIC_AGENT_URL` is set; in production it points at the mpv control API on `ieee-tamu-5B` (`http://192.168.1.10:8787`). The pod needs egress to that address on TCP 8787.

The print slash commands (`/print`, `/print-status`, `/print-cancel`) are disabled unless `PRINT_AGENT_URL` is set; in production it points at the print-agent on `ieee-tamu-5B` (`http://192.168.1.10:8788`). The pod needs egress to that address on TCP 8788.

To restrict who can control playback, set `MUSIC_ALLOWED_ROLE_IDS` and/or `MUSIC_ALLOWED_CHANNEL_IDS` in `discord-configmap.yaml`. If no role allowlist is set, only members with **Manage Server** can use the commands. `MUSIC_AGENT_TOKEN` can be added to `discord-secrets` to match the player's `tokenFile`.

Printing uses the same access model: set `PRINT_ALLOWED_ROLE_IDS` and/or `PRINT_ALLOWED_CHANNEL_IDS`. `PRINT_AGENT_TOKEN` can be added to `discord-secrets` to match the print agent's `tokenFile`; `PRINT_MAX_FILE_MB` controls the upload limit.
