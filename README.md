# MIDDLEMAN

![Screenshot of Middleman](middleman.png)

First, run a containerized Chromium with active CDP (Chrome DevTools Protocol):
```bash
podman run -p 7000:80 -p 9222:9222 ghcr.io/remotebrowser/chromium-live
```

Open `localhost:7000` to view the containerized desktop live.

Then, run:
```bash
export CDP_URL=http://127.0.0.1:9222
uv run middleman.py
```

Open `localhost:3000` and pick one of the examples.

See also [DEVELOPMENT.md](DEVELOPMENT.md).