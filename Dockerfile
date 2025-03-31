FROM openjdk:17-jdk-slim

WORKDIR /minecraft

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Minecraft version and Fabric loader version
ENV MC_VERSION=1.20.1
ENV FABRIC_VERSION=0.15.6

# Download Fabric server
RUN curl -OJ https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${FABRIC_VERSION}/0.11.2/server/jar

# Create directories
RUN mkdir -p mods/

# Download performance mods
RUN curl -L -o mods/fabric-api.jar https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar && \
    curl -L -o mods/fabric-language-kotlin.jar https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar && \
    curl -L -o mods/lithium.jar https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar && \
    curl -L -o mods/starlight.jar https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.2%2B1.20/starlight-1.1.2%2B1.20.jar && \
    curl -L -o mods/ferritecore.jar https://cdn.modrinth.com/data/uXXizFIs/versions/RbR7ADfF/ferritecore-6.0.0-fabric.jar && \
    curl -L -o mods/lazydfu.jar https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar && \
    curl -L -o mods/entityculling.jar https://cdn.modrinth.com/data/NNAgCjsB/versions/NwQcsoO4/entityculling-fabric-1.6.2-mc1.20.1.jar && \
    curl -L -o mods/krypton.jar https://cdn.modrinth.com/data/fQEb0iXm/versions/jiDwS0W1/krypton-0.2.3.jar && \
    curl -L -o mods/c2me.jar https://cdn.modrinth.com/data/VSNURh3q/versions/t4juSkze/c2me-fabric-mc1.20.1-0.2.0%2Balpha.10.91.jar

# Server properties
COPY server.properties .
COPY eula.txt .

# Volume for world data
VOLUME /minecraft/world

# Expose Minecraft port
EXPOSE 25565

# Start the server
CMD ["java", "-Xmx4G", "-Xms2G", "-XX:+UseG1GC", "-jar", "fabric-server-launch.jar", "nogui"]