# Cloudflared

Because the cluster is behind the TAMU firewall, we need to somehow expose the cluster to the internet. We use cloudflare tunnels (cloudflared) to do this.

In the ieeetamu.org DNS settings, *.ieeetamu.org is set to point to the cloudflare tunnel which forwards all trafffic to the traefik service - allowing us to route to the other services running internally on the cluster.