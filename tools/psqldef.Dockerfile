
FROM golang:1.23-bookworm AS builder
RUN go install github.com/sqldef/sqldef/cmd/psqldef@v0.17.19

FROM debian:bookworm-slim
COPY --from=builder /go/bin/psqldef /usr/bin/psqldef
ENTRYPOINT ["/usr/bin/psqldef"]
