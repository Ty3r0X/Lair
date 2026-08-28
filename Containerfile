FROM docker.io/library/alpine:latest AS assembler

RUN apk add --no-cache \
    make \
    perl \
    libxml2-utils \
    zola

WORKDIR /root/lair
COPY . .

RUN make build
RUN make convert

FROM scratch

COPY --from=assembler /root/lair/public/ /
