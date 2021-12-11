FROM sosedoff/pgweb:0.11.9

# install apk packages
RUN apk add openvpn --no-cache && \
    rm -rf /var/cache/apk/*

USER nobody