#!/bin/sh
set -e

sudo tailscaled --encrypt-state=false --hardware-attestation=false --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &

/app/.venv/bin/python /app/middleman.py &

if [ -n "$TS_AUTHKEY" ]; then
  echo "Starting Tailscale..."
  sudo tailscale up --authkey="$TS_AUTHKEY" --hostname=middleman &
else
  echo "Skipping Tailscale setup (no TS_AUTHKEY provided)"
fi

# Keep the container running
echo "Container setup complete. Keeping container alive..."
wait
