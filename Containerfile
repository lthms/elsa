FROM quay.io/fedora/fedora-coreos:stable

RUN curl -sSfL -o /usr/bin/k3s \
      "https://github.com/k3s-io/k3s/releases/download/v1.31.4%2Bk3s1/k3s" && \
    chmod +x /usr/bin/k3s

RUN curl -sSfL \
      "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.145.0/otelcol-contrib_0.145.0_linux_amd64.tar.gz" | \
    tar xz -C /usr/bin otelcol-contrib && \
    chmod +x /usr/bin/otelcol-contrib
