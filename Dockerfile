FROM nousresearch/hermes-agent:latest

ENV HERMES_INFERENCE_PROVIDER=ollama-cloud
ENV HERMES_MODEL=kimi-k2.5:cloud
ENV OLLAMA_BASE_URL=https://ollama.com/v1

EXPOSE 8642

CMD ["gateway", "run"]
