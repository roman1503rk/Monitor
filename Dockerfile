FROM alpine:latest

RUN apk add --no-cache util-linux bash

WORKDIR /app
COPY worker.sh /app/worker.sh
RUN chmod +x /app/worker.sh

VOLUME /shared

ENTRYPOINT ["/app/worker.sh"]
