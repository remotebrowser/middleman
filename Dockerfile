FROM mirror.gcr.io/library/python:3.13-slim-bookworm

COPY --from=ghcr.io/astral-sh/uv:0.8.4 /uv /uvx /bin/

RUN apt-get update -y && apt-get install -y --no-install-recommends sudo curl chromium

RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list >/dev/null && \
    apt-get update -y && apt-get install -y tailscale && \
    mkdir -p /var/lib/tailscale /var/run/tailscale

ENV PYTHONUNBUFFERED=1
ENV PYTHONFAULTHANDLER=1

WORKDIR /app

COPY pyproject.toml uv.lock* ./

ENV VENV_PATH="/app/.venv"
ENV UV_FROZEN=1
RUN uv sync --no-dev --no-install-workspace

COPY middleman.py /app/middleman.py
COPY patterns /app/patterns/
COPY entrypoint.sh /app/entrypoint.sh

RUN uv sync --no-dev

ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 3000

RUN useradd -m -s /bin/bash middleman && \
    chown -R middleman:middleman /app && \
    usermod -aG sudo middleman && \
    echo 'middleman ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER middleman

ENTRYPOINT ["/app/entrypoint.sh"]
