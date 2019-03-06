FROM golang:1.12-alpine as builder

RUN apk add git make curl
ADD . /go/src/github.com/prometheus/alertmanager
WORKDIR /go/src/github.com/prometheus/alertmanager
RUN make build

FROM        prom/busybox:latest
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

COPY --from=builder /go/src/github.com/prometheus/alertmanager/amtool                       /bin/amtool
COPY --from=builder /go/src/github.com/prometheus/alertmanager/alertmanager                 /bin/alertmanager
COPY --from=builder /go/src/github.com/prometheus/alertmanager/examples/ha/alertmanager.yml /etc/alertmanager/alertmanager.yml

RUN mkdir -p /alertmanager && \
    chown -R nobody:nogroup etc/alertmanager /alertmanager

USER       nobody
EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]
