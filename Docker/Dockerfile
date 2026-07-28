FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Dependencias
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    x11vnc \
    xvfb \
    fluxbox \
    novnc \
    websockify \
    python3 \
    libgtk2.0-dev \
    libwxgtk3.0-gtk3-dev \
    libsdl1.2-dev \
    libncurses5-dev \
    liballegro4-dev \
    && rm -rf /var/lib/apt/lists/*

# Clonar repo
WORKDIR /opt
RUN git clone https://github.com/virtualagc/virtualagc.git

# Compilar
WORKDIR /opt/virtualagc
RUN make

# Copiar script de arranque
COPY start.sh /start.sh
# The following changed per issue #1341
#RUN chmod +x /start.sh
RUN sed -i 's/\r$//' /start.sh \
    && chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
