# tarpn-docker

Experimental Docker build for TARPN http://tarpn.net/t/packet_radio_networking.html

To build:

    docker build -t tarpn .
    
Edit the config files in conf (these are copied into the container at runtime)

To run:

    docker run -P \
      -v $PWD/conf/chatconfig.cfg:/home/pi/bpq/chatconfig.cfg \
      -v $PWD/conf/node.ini:/home/pi/node.ini \
      -it -u root --privileged tarpn:latest
    
The `--privileged` flag allows for I2C device access from within the container. `-P` publishes all the ports defined in the 
Dockerfile. 
