# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

FROM quay.io/fedora/fedora-coreos:stable

RUN curl -sSfL -o /usr/bin/k3s \
      "https://github.com/k3s-io/k3s/releases/download/v1.35.1%2Bk3s1/k3s" && \
    chmod +x /usr/bin/k3s

RUN curl -sSfL \
      "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.145.0/otelcol-contrib_0.145.0_linux_amd64.tar.gz" | \
    tar xz -C /usr/bin otelcol-contrib && \
    chmod +x /usr/bin/otelcol-contrib
