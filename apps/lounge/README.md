# Lounge

Web UI for the IEEE TAMU officer lounge. It authenticates through the portal's
OpenID Connect provider and proxies playback controls to the `lounge-music`
agent on `ieee-tamu-5B`.

- Host: `lounge.ieeetamu.org`
- Image: `ghcr.io/ieee-tamu/lounge:0.2.1`
- Portal client: `oidc__Pe6cCksIt9m5wJX` (managed in `/admin/oidc-clients`)
- Music agent: `http://192.168.1.10:8787`

The pod needs egress to the lounge host on TCP 8787 and to
`portal.ieeetamu.org` on TCP 443. Only Traefik is allowed to reach the app on
TCP 3000.

`lounge-secrets` contains `PORTAL_OIDC_CLIENT_SECRET` and `SESSION_SECRET`.
The matching OIDC client secret and signing key live in `secrets/portal.yaml`.
