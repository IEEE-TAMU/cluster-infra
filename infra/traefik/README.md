# Traefik

Traefik comes included with k3s, and is configured for our needs in this folder.

Since we use cloudflared to expose the cluster to the internet, we need to configure Traefik to use the `X-Forwarded-For` header to get the real IP address of the client. This is done by enabling the [`cloudflarewarp`](./traefik-realip-middleware.yaml) plugin middleware globally.
Additionally, we don't bother with HTTPS certificates since all traffic comes from the cloudflare tunnel which uses HTTPS when enthering the tunnel.

The traefik dashboard is available at [traefik.ieeetamu.org](https://traefik.ieeetamu.org).