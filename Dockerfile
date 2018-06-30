FROM alpine
MAINTAINER @biskyt

# Install transmission
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl shadow sed tini inotify-tools\
                transmission-daemon transmission-cli && \
    dir="/var/lib/transmission-daemon" && \
    file="$dir/info/settings.json" && \
    mv /var/lib/transmission $dir && \
    usermod -d $dir transmission && \
    [[ -d /downloads ]] || mkdir -p /downloads && \
    [[ -d /incomplete ]] || mkdir -p /incomplete && \
    [[ -d $dir/info/blocklists ]] || mkdir -p $dir/info/blocklists && \
    /bin/echo -e '{\n    "blocklist-enabled": 0,' >$file && \
    echo '    "dht-enabled": true,' >>$file && \
    echo '    "download-dir": "/downloads",' >>$file && \
    echo '    "incomplete-dir": "/incomplete",' >>$file && \
    echo '    "incomplete-dir-enabled": true,' >>$file && \
    echo '    "download-limit": 100,' >>$file && \
    echo '    "download-limit-enabled": 0,' >>$file && \
    echo '    "encryption": 1,' >>$file && \
    echo '    "max-peers-global": 200,' >>$file && \
    echo '    "peer-port": 51413,' >>$file && \
    echo '    "peer-socket-tos": "lowcost",' >>$file && \
    echo '    "pex-enabled": 1,' >>$file && \
    echo '    "port-forwarding-enabled": 0,' >>$file && \
    echo '    "queue-stalled-enabled": true,' >>$file && \
    echo '    "ratio-limit-enabled": true,' >>$file && \
    echo '    "rpc-authentication-required": 1,' >>$file && \
    echo '    "rpc-password": "transmission",' >>$file && \
    echo '    "rpc-port": 9091,' >>$file && \
    echo '    "rpc-username": "transmission",' >>$file && \
    echo '    "rpc-whitelist": "127.0.0.1",' >>$file && \
    echo '    "upload-limit": 100,' >>$file && \
    echo '    "umask": 1,' >>$file && \
    /bin/echo -e '    "upload-limit-enabled": 0\n}' >>$file && \
    chown -Rh transmission. $dir && \
    rm -rf /tmp/* && \
    mkdir -p /portforward && \
    touch /portforward/port.txt

COPY transmission.sh /usr/
COPY portforward_watcher.sh /usr/bin/

ENV TRUSER=admin
ENV TRPASSWD=admin
ENV TZ=Europe/London

EXPOSE 9091 51413/tcp 51413/udp

HEALTHCHECK --interval=60s --timeout=15s \
            CMD curl -L 'https://api.ipify.org' || netstat -lntp | grep -q '0\.0\.0\.0:9091' || exit 1

VOLUME ["/var/lib/transmission-daemon"]
VOLUME /portforward /downloads /incomplete

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/transmission.sh"]
