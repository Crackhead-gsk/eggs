# Pterodactyl Tor Web Hosting

This image runs Nginx, PHP-FPM 8.2 and one Tor v3 onion service per Pterodactyl server.

## Image

The GitHub Actions workflow publishes:

`ghcr.io/crackhead-gsk/pterodactyl-tor-hosting:latest`

## Egg

Import `pterodacty-eggs/egg-tor-web-hosting.json` into Pterodactyl.

Each Pterodactyl server must have its own persistent server volume. The Tor identity is stored in `/home/container/.tor/hidden_service`; deleting that directory changes the onion address. Back it up securely and never publish the private key.

## Build

Push changes to `main` or run the **Build and publish Tor Hosting image** workflow manually from GitHub Actions.

The first image build must complete before selecting the image in Pterodactyl. For a private GHCR package, configure image-pull credentials on every Wings node; alternatively make the package public.

## Notes

Nginx listens only on 127.0.0.1:8080 and Tor maps onion port 80 to it. PHP-FPM listens only on 127.0.0.1:9000. Review resource limits, outbound network policy, backups and abuse controls before offering multi-tenant hosting. This image is a starting implementation and has not been load-tested for hundreds of tenants.
