FROM alpine
MAINTAINER wiserain

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3 && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --no-cache --upgrade pip setuptools wheel && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
	echo "**** install dependencies for plugin: telegram ****" && \
	apk add --no-cache --virtual=build-deps gcc python3-dev libffi-dev musl-dev openssl-dev && \
	pip install --upgrade python-telegram-bot==12.8 PySocks && \
	apk del --purge --no-cache build-deps && \
	echo "**** install dependencies for plugin: cfscraper ****" && \
	apk add --no-cache --virtual=build-deps g++ gcc python3-dev libffi-dev openssl-dev && \
	pip install --upgrade cloudscraper && \
	apk del --purge --no-cache build-deps && \
	echo "**** install dependencies for plugin: convert_magnet ****" && \
	apk add --no-cache boost-python3 libstdc++ && \
	echo "**** install dependencies for plugin: decompress ****" && \
	apk add --no-cache unrar && \
	pip install --upgrade \
		rarfile && \
	echo "**** install dependencies for plugin: misc ****" && \
	pip install --upgrade \
		transmissionrpc \
		youtube-dl \
                rarfile \
		irc_bot \
		beautifulsoup4\
		mechanicalsoup \
		requests \
		certifi \
		chardet \
		idna \
		urllib3 \
		cython \
		six \
		future \
	echo "**** install flexget ****" && \
	apk add --no-cache --virtual=build-deps gcc libxml2-dev libxslt-dev libc-dev python3-dev jpeg-dev && \
	pip install --upgrade --force-reinstall \
		flexget && \
	apk del --purge --no-cache build-deps && \
	apk add --no-cache libxml2 libxslt jpeg && \
	echo "**** system configurations ****" && \
	apk --no-cache add bash bash-completion tzdata && \
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
