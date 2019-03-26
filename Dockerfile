FROM balenalib/armv7hf-debian:stretch-build

RUN apt-get update && apt-get -y upgrade

RUN apt-get -qy install wget apt-utils unzip

ENV TARPN_USER pi
ENV TARPN_PWD pi
ENV TARPN_UID 8983

RUN groupadd -r -g $TARPN_UID $TARPN_USER && \
    useradd -r -u $TARPN_UID -G $TARPN_USER -g $TARPN_USER $TARPN_USER && \
    adduser $TARPN_USER sudo && \
    echo "pi:pi" | chpasswd

RUN echo '$TARPN_USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/pi && \
    chown -R $TARPN_USER:$TARPN_USER /home/pi

WORKDIR /home/pi

# Tarpn Install
RUN apt-get install --reinstall iputils-ping

## Create a BPQ directory below /home/pi
RUN mkdir -p /home/pi/bpq

## Get RUNBPQ.SH
COPY tarpn-scripts/runbpq.sh /usr/local/sbin/runbpq.sh
RUN chmod +x /usr/local/sbin/runbpq.sh

## Get CONFIGURE_NODE_INI.SH
COPY tarpn-scripts/configure_node_ini.sh configure_node_ini.sh
RUN chmod +x configure_node_ini.sh 

## Get TARPN
COPY tarpn-scripts/tarpn /usr/local/sbin/tarpn
RUN chmod +x /usr/local/sbin/tarpn

## Update packages (again?)
RUN apt-get -y update && \
    apt-get clean && \
    apt-get -y autoremove

## Install ax25-tools
RUN apt-get -y install ax25-tools ax25-apps i2c-tools

## Install some other useful stuff
RUN apt-get -y install screen libcap2-bin libpcap0.8 libpcap-dev

## Install minicom
RUN apt-get -y install minicom

## install  G8BPQ's version of Minicom
RUN mkdir -p /home/pi/minicom
COPY tarpn-scripts/piminicom.zip piminicom.zip
COPY tarpn-scripts/minicom.scr minicom.scr
RUN unzip piminicom.zip && \
    chmod +x piminicom
    
## install of conspy, telnet, and vim
RUN apt-get -y install conspy telnet vim
RUN echo "syntax on" > .vimrc

## Get PARAMS.ZIP
COPY tarpn-scripts/params.zip params.zip
RUN unzip params.zip && \
    chmod +x pitnc* && \
    mv pitnc* /usr/local/sbin

## Get PI-LIN-BPQ
COPY tarpn-scripts/bpq_6_0_14_12_sep_2017.zip bpq/linbpq.zip
RUN cd bpq && \
    unzip linbpq.zip && \
    cp pilinbpq.dms linbpq && \
    chmod +x linbpq && \
    setcap "CAP_NET_RAW=ep CAP_NET_BIND_SERVICE=ep" linbpq 

## Get piTermBPQ  -- node operations console
COPY tarpn-scripts/piTermTCP.zip piTermTCP.zip
RUN unzip piTermTCP.zip && \
    rm -f piTermTCP.zip && \
    chmod +x piTermTCP && \
    mv piTermTCP /home/pi/Desktop

## Get Ring noises folder
COPY tarpn-scripts/ringnoises.zip ringnoises.zip
RUN mkdir ringfolder && \
    cd ringfolder && \
    unzip ../ringnoises.zip && \
    rm -f ../ringnoises.zip

RUN apt-get update && \
    apt-get -y dist-upgrade
#    apt-get install -y rpi-update
#RUN rpi-update
RUN apt-get install systemd

RUN touch /usr/local/sbin/tarpn_start1_finished.flag
RUN touch /usr/local/sbin/tarpn_start1dl.flag
RUN touch /usr/local/sbin/tarpn_start2.flag

#COPY tarpn-scripts/node.ini node.ini
#COPY tarpn-scripts/node.ini bpq/node.ini

RUN echo "http://tarpn.net/2017aug" > /usr/local/sbin/source_url.txt

# Generate node.ini
COPY tarpn-scripts/configure_node_ini.sh configure_node_ini.sh
RUN chmod +x configure_node_ini.sh && \
    ./configure_node_ini.sh

RUN cat node.ini

COPY tarpn-scripts/boilerplate.cfg bpq/boilerplate.cfg
COPY tarpn-scripts/make_local_cfg.sh bpq/make_local_cfg.sh

RUN chmod +x bpq/make_local_cfg.sh
#    ./make_local_cfg.sh

RUN chown -R $TARPN_USER:$TARPN_USER /home/pi

COPY scripts scripts
RUN chown -R $TARPN_USER:$TARPN_USER scripts && \
    chmod +x scripts/*
ENV PATH /usr/local/sbin:/home/pi/scripts:$PATH

USER $TARPN_USER

EXPOSE 8011

EXPOSE 8085

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run-tarpn"]
