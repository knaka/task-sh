FROM debian:bullseye-20230612-slim
ENV LANG C.UTF-8
ENV TZ UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
