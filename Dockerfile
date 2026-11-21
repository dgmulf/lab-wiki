FROM ghcr.io/typst/typst:0.15.1@sha256:032e292249bcd378480cc7c142cfa324b63ef8aadeb88d7e7230320c4c9c422f
# Typst's preview server listens on loopback. Forward it to the container port.
RUN apk add --no-cache socat
WORKDIR /work
EXPOSE 8080
