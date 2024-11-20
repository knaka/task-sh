FROM debian:bullseye-20230612-slim
ENV LANG C.UTF-8
ENV TZ UTC

RUN apt-get update
RUN apt-get install -y attr
WORKDIR /work
