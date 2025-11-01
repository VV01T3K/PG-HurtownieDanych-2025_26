FROM mcr.microsoft.com/devcontainers/base:bookworm

COPY --from=oven/bun /usr/local/bin/bun /usr/local/bin/bun
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY --from=ghcr.io/astral-sh/ruff:latest /ruff /usr/local/bin/ruff