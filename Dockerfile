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
	apk add --no-cache bash py3-lxml g++ gcc ffmpeg libmagic boost-python3 libstdc++ && \
	pip3 install --upgrade \
		transmissionrpc \
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
		six==1.10.0 \
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
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/libtorrent-rasterbar.so.10 /usr/lib/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/libtorrent*.so /usr/lib/python3.7/site-packages/
COPY --from=emmercm/libtorrent:1.2.2-alpine /usr/lib/python3.7/site-packages/python_libtorrent-*.egg-info /usr/lib/python3.7/site-packages/


# add default volumes
VOLUME /config /data
WORKDIR /config


# expose port for flexget webui
EXPOSE 3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]

