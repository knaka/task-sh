
FROM golang:1.23-bookworm AS builder
ARG version=v0.0.0
RUN go install github.com/sqldef/sqldef/cmd/psqldef@$version

FROM debian:bookworm-slim
COPY --from=builder /go/bin/psqldef /usr/bin/psqldef
ENTRYPOINT ["/usr/bin/psqldef"]
