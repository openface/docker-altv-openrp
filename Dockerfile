FROM debian:10
LABEL maintainer="https://github.com/openface"
WORKDIR /altv

# Install Prereqs
RUN apt-get update && \
    apt-get install -y wget unzip curl libc-bin gettext-base

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && \
	apt-get install -y nodejs

# Install AltV
ARG altv_server_version=beta
RUN bash -c 'mkdir {data,modules,resources,resources-data}' && \
	wget --no-cache -O altv-server https://cdn.altv.mp/server/${altv_server_version}/x64_linux/altv-server && \
	wget --no-cache -O modules/libnode-module.so https://cdn.altv.mp/node-module/${altv_server_version}/x64_linux/modules/libnode-module.so && \
	wget --no-cache -O libnode.so.72 https://cdn.altv.mp/node-module/${altv_server_version}/x64_linux/libnode.so.72 && \
	wget --no-cache -O data/vehmodels.bin https://cdn.altv.mp/server/${altv_server_version}/x64_linux/data/vehmodels.bin && \
	wget --no-cache -O data/vehmods.bin https://cdn.altv.mp/server/${altv_server_version}/x64_linux/data/vehmods.bin

# Install OpenRP
RUN wget --no-cache -O /tmp/postgres-wrapper.zip https://github.com/team-stuyk-alt-v/altV-Postgres-Wrapper/archive/master.zip && \
	unzip /tmp/postgres-wrapper.zip -d /tmp && \
	mv /tmp/altV-Postgres-Wrapper-master /altv/resources/postgres-wrapper && \
	rm /tmp/postgres-wrapper.zip && \
	wget --no-cache -O /tmp/altv-open-roleplay.zip https://github.com/team-stuyk-alt-v/altV-Open-Roleplay/archive/master.zip && \
	unzip /tmp/altv-open-roleplay.zip -d /tmp && \
	mv /tmp/altV-Open-Roleplay-master /altv/resources/orp && \
	rm /tmp/altv-open-roleplay.zip && \
	npm init --yes && \
	npm install --save typeorm pg sjcl

# OpenRP ORM
ENV DB_USERNAME postgres
ENV DB_PASSWORD postgres

COPY database.mjs.template ./resources/orp/server/configuration/database.mjs.template
RUN envsubst < ./resources/orp/server/configuration/database.mjs.template > ./resources/orp/server/configuration/database.mjs

# TOS Agreement
# By using this container, you automatically agree to the terms set forth by AltV and OpenRP
COPY terms-and-conditions.json ./resources/orp/
RUN sed -i 's/do_you_agree: false/do_you_agree: true/g' ./resources/orp/server/configuration/terms-and-conditions.mjs

# AltV configuration
ENV NAME "Dockerized Open RP"
ENV DESCRIPTION "Demonstration Purposes Only"
ENV PLAYERS 1000
ENV ANNOUNCE false
ENV TOKEN _
ENV WEBSITE twitch.tv/stuykgaming
ENV LANGUAGE en
ENV DEBUG true
        
COPY server.cfg.template .
RUN envsubst < ./server.cfg.template > ./server.cfg

# Cleanup
RUN apt-get purge -y wget unzip curl && apt-get clean

# Start AltV Server
COPY start_server.sh .
RUN chmod +x start_server.sh
RUN chmod +x altv-server

USER 0

ENTRYPOINT ["/altv/start_server.sh"]
CMD ["bash"]
