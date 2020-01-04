FROM alpine
MAINTAINER wiserain

RUN \
	echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
	echo "@main http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
	echo "@community http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
        apk update && \
        apk add --upgrade apk-tools && \
	apk add --no-cache python3-dev && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	echo "**** install flexget and addons ****" && \
	apk --no-cache add shadow ca-certificates tzdata py3-cryptography && \
	apk add --no-cache --virtual=build-deps python3-dev libffi-dev openssl-dev && \
	apk add --no-cache bash py3-lxml g++ gcc ffmpeg libmagic boost-python3 libstdc++ atomicparsley@testing && \
	pip3 install --upgrade \
		transmissionrpc \
		rarfile \
		irc_bot \
		beautifulsoup4==4.6.0 \
		mechanicalsoup \
		requests==2.21.0 \
		certifi==2017.4.17 \
		chardet==3.0.3 \
		idna==2.5 \
		urllib3==1.24.2 \
		youtube-dl \
		cython \
		six==1.13.0 \
		future==0.16.0 \
		flexget && \
	sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY files/ /

# copy libtorrent libs
COPY --from=emmercm/libtorrent:1.2.3-alpine /usr/lib/libtorrent-rasterbar.a /usr/lib/
COPY --from=emmercm/libtorrent:1.2.3-alpine /usr/lib/libtorrent-rasterbar.la /usr/lib/
COPY --from=emmercm/libtorrent:1.2.3-alpine /usr/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.3-alpine /usr/lib/python3.8/site-packages/libtorrent.cpython-38-x86_64-linux-gnu.so /usr/lib/python3.8/site-packages/
COPY --from=emmercm/libtorrent:1.2.3-alpine /usr/lib/python3.8/site-packages/python_libtorrent-1.2.3-py3.8.egg-info /usr/lib/python3.8/site-packages/

# symlink libtorretn libs
RUN \
	cd /usr/lib && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so && \
	ln -s libtorrent-rasterbar.so.10.0.0 libtorrent-rasterbar.so.10

# add default volumes
VOLUME /config /downloads
WORKDIR /config


# expose port for flexget webui
EXPOSE 3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]
