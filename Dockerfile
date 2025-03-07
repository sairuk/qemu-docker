FROM debian:trixie-slim

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN "true"

RUN apt-get update \
    && apt-get --no-install-recommends -y install \
 	tini \
	wget \
        ovmf \
	socat \
 	nginx \
        swtpm \
	procps \
	iptables \
	iproute2 \
        apt-utils \
	dnsmasq \
	net-tools \
        qemu-utils \
	ca-certificates \
	netcat-openbsd \
	qemu-system-x86 \
    && apt-get clean \
    && novnc="1.4.0" \
    && mkdir -p /usr/share/novnc \
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v"$novnc".tar.gz -O /tmp/novnc.tar.gz -q \
    && tar -xf /tmp/novnc.tar.gz -C /tmp/ \
    && cd /tmp/noVNC-"$novnc" \
    && mv app core vendor package.json *.html /usr/share/novnc \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY nginx.conf /etc/nginx/sites-enabled/novnc.conf

RUN chmod +x /run/*.sh

VOLUME /storage
EXPOSE 22 5900 8006

ENV CPU_CORES "1"
ENV RAM_SIZE "1G"
ENV DISK_SIZE "16G"
ENV BOOT "http://www.example.com/image.iso"

ARG VERSION_ARG "0.0"
RUN echo "$VERSION_ARG" > /run/version

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
