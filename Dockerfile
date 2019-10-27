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
	wget -nv --show-progress --progress=bar:force:noscroll -P . https://cdn.altv.mp/node-module/beta/x64_linux/update.json && \
	wget -nv --show-progress --progress=bar:force:noscroll -P . https://cdn.altv.mp/server/${altv_server_version}/x64_linux/altv-server && chmod +x altv-server && \
	wget -nv --show-progress --progress=bar:force:noscroll -P modules/ https://cdn.altv.mp/node-module/${altv_server_version}/x64_linux/modules/libnode-module.so && \
	wget -nv --show-progress --progress=bar:force:noscroll -P . https://cdn.altv.mp/node-module/${altv_server_version}/x64_linux/libnode.so.72 && \
	wget -nv --show-progress --progress=bar:force:noscroll -P data/ https://cdn.altv.mp/server/${altv_server_version}/x64_linux/data/vehmodels.bin && \
	wget -nv --show-progress --progress=bar:force:noscroll -P data/ https://cdn.altv.mp/server/${altv_server_version}/x64_linux/data/vehmods.bin && \
	wget -nv --show-progress --progress=bar:force:noscroll -P . https://cdn.altv.mp/others/start.sh && chmod +x start.sh

# Install OpenRP
RUN wget -nv --show-progress --progress=bar:force:noscroll -O /tmp/altv-open-roleplay.zip https://github.com/team-stuyk-alt-v/altV-Open-Roleplay/archive/master.zip && \
	unzip /tmp/altv-open-roleplay.zip -d /tmp && \
	cp -a /tmp/altV-Open-Roleplay-master/* . && \
	npm install && \
	rm /tmp/altv-open-roleplay.zip

# OpenRP ORM
ENV DB_USERNAME postgres
ENV DB_PASSWORD postgres

COPY database.json.template ./resources/orp/server/configuration/database.json.template
RUN envsubst < ./resources/orp/server/configuration/database.json.template > ./resources/orp/server/configuration/database.json

# TOS Agreement
# By using this container, you automatically agree to the terms set forth by AltV and OpenRP
COPY terms-and-conditions.json ./resources/orp/
RUN sed -i 's/do_you_agree: false/do_you_agree: true/g' ./resources/orp/terms-and-conditions.json

# AltV configuration
ENV NAME "Dockerized Open RP"
ENV DESCRIPTION "Demonstration Purposes Only"
ENV PLAYERS 64
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
USER 0
ENTRYPOINT ["/altv/start.sh"]
CMD ["bash"]
