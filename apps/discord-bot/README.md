# Discord Bot

This Discord bot listens to messages in the specified channel and re-posts everything from that channel through a GroupMe bot to an associated GroupMe group.

Discord role, channel, and guild IDs are defined once in [`discord-ids.yaml`](./discord-ids.yaml) with a comment for each. `discord-configmap.yaml` references them as `$(VARIABLE_NAME)` and kustomize substitutes the real IDs at build time.

It also exposes the lounge music slash commands. Those commands are disabled unless `MUSIC_AGENT_URL` is set; in production it points at the mpv control API on `ieee-tamu-5B` (`http://192.168.1.10:8787`). The pod needs egress to that address on TCP 8787.

Upcoming tracks can be reordered with `/move <from> <to>`; both positions use the same numbering as `/queue`. Spotify links are supported when an officer has connected the lounge's Spotify account from the lounge web app. Spotify manages its own queue, so `/move`, `/remove`, and `/clear` are unavailable while Spotify is the active source.

The print slash commands (`/print`, `/print-status`, `/print-cancel`) are disabled unless `PRINT_AGENT_URL` is set; in production it points at the print-agent on `ieee-tamu-5B` (`http://192.168.1.10:8788`). The pod needs egress to that address on TCP 8788.

To restrict who can control playback, set `MUSIC_ALLOWED_ROLE_IDS` and/or `MUSIC_ALLOWED_CHANNEL_IDS` in `discord-configmap.yaml`. If no role allowlist is set, only members with **Manage Server** can use the commands. `MUSIC_AGENT_TOKEN` can be added to `discord-secrets` to match the player's `tokenFile`.

Printing uses the same access model: set `PRINT_ALLOWED_ROLE_IDS` and/or `PRINT_ALLOWED_CHANNEL_IDS`. `PRINT_AGENT_TOKEN` can be added to `discord-secrets` to match the print agent's `tokenFile`; `PRINT_MAX_FILE_MB` controls the upload limit.

The 3D printer slash commands (`/3dprint`, `/3dprint-status`, `/3dprint-stop`) are disabled unless `BAMBU_AGENT_URL` is set; in production it points at the Bambu agent on `ieee-tamu-5B` (`http://192.168.1.10:8789`). The pod needs egress to that address on TCP 8789. `BAMBU_AGENT_TOKEN` can be added to `discord-secrets` to match the agent's `tokenFile`; `BAMBU_MAX_FILE_MB` controls the upload limit (25 MB by default to match Discord). `BAMBU_ALLOWED_ROLE_IDS` grants both **Officer** and **Projects Team** access.

`/3dprint` uploads the file first, then shows an ephemeral mapping UI with one select menu per sliced material. The embed lists both the sliced materials and the live AMS/external filaments; there is no automatic matching. Pressing **Start print** submits the selected tray IDs to the agent's `POST /start` endpoint.

When `BAMBU_NOTIFY_CHANNEL_ID` is set, the bot watches the printer and posts a print-finished/failed embed with a camera snapshot to that channel. It polls every `BAMBU_NOTIFY_POLL_SECONDS` (default 20) and only posts on an active → terminal transition, so restarts don't duplicate notifications.

## Lounge officer presence sensor

An ESP32 with a light sensor in the lounge posts whether the room light is on to
the bot's `/officer-status` endpoint. The bot keeps a minimal embed updated in
`#officer-bot-notifications` and marks the sensor offline after 90 seconds
without a heartbeat.

The endpoint is reachable from the lounge LAN through Traefik on any k3s node:

```
POST http://192.168.1.10/officer-status
```

`discord-ingressroute.yaml` exposes only the exact `/officer-status` path, and
only for `Host: 192.168.1.10`. Requests through the public Cloudflare tunnel use
a different host and return 404, so this endpoint never leaves the lounge LAN.
The rest of the bot API stays cluster-internal. Requests must send
`Authorization: Bearer <OFFICER_STATUS_API_KEY>`; the key lives in
`secrets/discord.yaml`.

The channel comes from `discord-ids.yaml`
(`OFFICER_BOT_NOTIFICATIONS_CHANNEL_ID`). The device ID, Wi-Fi credentials, and
key are flashed in the firmware under `discord/firmware/lounge-light-sensor`.
