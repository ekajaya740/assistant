FROM ghcr.io/dmno-dev/varlock:latest AS varlock

FROM ghcr.io/openclaw/openclaw:main
COPY --from=varlock /usr/local/bin/varlock /usr/local/bin/varlock

# Set entrypoint to validate env vars at runtime using varlock
ENTRYPOINT ["varlock", "run", "--"]
CMD ["openclaw"]
