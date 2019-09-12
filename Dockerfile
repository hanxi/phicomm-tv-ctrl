FROM alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add build-base git readline-dev autoconf
COPY build.sh /build.sh
RUN sh build.sh

FROM alpine
COPY --from=builder /phicomm-tv-ctrl/bin /phicomm-tv-ctrl
WORKDIR /phicomm-tv-ctrl
ENTRYPOINT ["./start.sh]

