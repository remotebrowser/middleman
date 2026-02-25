# MIDDLEMAN

![Screenshot of Middleman](middleman.png)

See also [DEVELOPMENT.md](DEVELOPMENT.md).

Middleman can run via direct CDP or via Chrome Fleet.

## Direct CDP Connection

First, run a containerized Chromium with CDP (Chrome DevTools Protocol) enabled:
```bash
podman run -p 7000:80 -p 9222:9222 ghcr.io/remotebrowser/chromium-live
```

Open `localhost:7000` to view the containerized desktop live.

Then, launch Middleman with the proper websocket URL for CDP:
```bash
CDP_WEBSOCKET_URL=$(
  curl -s http://127.0.0.1:9222/json/list \
  | jq -r '.[0].webSocketDebuggerUrl'
)
export CDP_WEBSOCKET_URL
uv run middleman.py
```

Open `localhost:3000` and pick one of the examples.

## Using Chrome Fleet

Run Chrome Fleet, then set the `CHROMEFLEET_URL` environment variable for Middleman:

```bash
export CHROMEFLEET_URL=http://127.0.0.1:8300 
uv run middleman.py
```

Open `localhost:3000` and pick one of the examples.
