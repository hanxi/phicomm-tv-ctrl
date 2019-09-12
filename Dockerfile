FROM alpine AS builder
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add build-base git readline-dev autoconf
COPY build.sh /build.sh
RUN sh build.sh

FROM alpine
RUN apk add --no-cache tini
COPY --from=builder /skynet-bin.tar.gz /
RUN tar -zxvf /skynet-bin.tar.gz

RUN mkdir /phicomm-tv-ctrl
WORKDIR /phicomm-tv-ctrl
RUN ln -s /skynet-bin skynet
COPY etc /phicomm-tv-ctrl/etc
COPY lualib /phicomm-tv-ctrl/lualib
COPY service /phicomm-tv-ctrl/service
COPY static /phicomm-tv-ctrl/static
COPY start.sh /phicomm-tv-ctrl/start.sh
RUN chmod +x start.sh && chmod +x skynet/skynet

ENV PORT=80
ENV TV_HOST=192.168.2.3:8080
ENV BASE_URL=
EXPOSE 80
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./start.sh"]

