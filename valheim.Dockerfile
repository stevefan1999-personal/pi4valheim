FROM debian:bullseye

LABEL maintainer="Tranko"

# Install tools required for the project
# Run 'docker build --no-cache .' to udpate dependencies
RUN dpkg --add-architecture armhf
RUN apt update && apt full-upgrade -y
RUN apt install -y \
    gcc-arm-linux-gnueabihf \
    git \
    make \
    cmake \
    python3 \
    curl \
    libsdl2-2.0-0 \
    nano \
    libc6:armhf \
    libncurses5:armhf \
    libstdc++6:armhf \
    libssl1.0.0:armhf

# Install the box86 to emulate x86 platform (for steamcmd cliente)
WORKDIR /root
RUN git clone https://github.com/ptitSeb/box86
RUN git clone https://github.com/ptitSeb/box64

## Box86 installation
WORKDIR /root/box86/build
RUN cmake .. -DSD845=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN make -j8;
RUN make install

## Box64 installation
WORKDIR /root/box64/build
RUN cmake .. -DSD845=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN make -j8; 
RUN make install

# Cleaning the image
WORKDIR /root
RUN rm -r /root/box86
RUN rm -r /root/box64

# Install steamcmd and download the valheim server:
WORKDIR /root/steam
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
# RUN export DEBUGGER="/usr/local/bin/box86"
ENV BOX86_DYNAREC "0"
ENV DEBUGGER "/usr/local/bin/box86"
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous +force_install_dir /root/svends +app_update 276060 validate +quit

# Specific for run Valheim server
EXPOSE 27015/udp
WORKDIR /root
COPY bootstrap .
CMD ["/root/bootstrap"]
