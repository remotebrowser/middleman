# Middleman via Dokku

This guide explains how to set up a [Dokku](https://dokku.com) server for Middleman deployment with [Tailscale](https://tailscale.com) support.

On a fresh host machine (tested on Debian 12), first install [Podman](https://podman.io) and verify it works properly:
```bash
sudo apt install -y podman
sudo podman run hello-world
```

Enable Podman system socket:
```bash
sudo systemctl enable --now podman.socket
systemctl status podman.socket --no-pager
```

Override the socket path by running `sudo systemctl edit podman.socket` and edit the contents to (note the empty `ListenStream`):

```
[Socket]
ListenStream=
ListenStream=/run/podman.sock
SocketMode=0666
```

(The above step is crucial because `sudo chmod 666 /run/podman.sock` doesn't survive reboots. The `/run` directory is a temporary RAM-backed filesystem that gets wiped on boot, and the Podman socket is recreated by [systemd](https://systemd.io) with its default permissions each time.)

Reboot the machine, then log in again and run this quick test (it should display full Podman information without throwing any errors):
```bash
CONTAINER_HOST="unix:///run/podman.sock" podman --remote info
```

Also run this simple check:
```bash
CONTAINER_HOST="unix:///run/podman.sock" podman --remote run hello-world
```

Install and configure Tailscale on the host machine by following [the official guide](https://tailscale.com/kb/1031/install-linux):
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Verify that the machine appears on the [Tailscale admin page](https://login.tailscale.com/admin/machines).

Install Dokku by following the [official installation guide](https://dokku.com/docs/getting-started/installation):
```bash
wget -NP . https://dokku.com/install/v0.37.2/bootstrap.sh
sudo DOKKU_TAG=v0.37.2 bash bootstrap.sh
```

Add at least one SSH key for manual deployment.

Create the app:
```bash
dokku apps:create middleman
dokku ports:add middleman http:80:3000
dokku ports:add middleman https:443:3000
dokku config:set middleman CONTAINER_HOST="unix:///run/podman.sock"
dokku docker-options:add middleman deploy "--cap-add=NET_ADMIN"
dokku docker-options:add middleman deploy "--cap-add=NET_RAW"
dokku docker-options:add middleman deploy "--device=/dev/net/tun:/dev/net/tun"
dokku docker-options:add middleman deploy,run "-v /run/podman.sock:/run/podman.sock"
```

Obtain the auth key from the Tailscale admin and set it:
```bash
dokku config:set middleman TS_AUTHKEY=your-tailscale-auth-key
```

Optionally set the domain as needed:
```bash
dokku domains:set middleman your-domain
```

Deploy Middleman to this Dokku instance manually.
