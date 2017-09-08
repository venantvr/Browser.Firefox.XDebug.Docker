FROM ubuntu:17.04

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /home/developer

RUN apt-get update && apt-get install -y firefox
RUN apt-get update && apt-get install -y wget
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update
RUN apt-get install google-chrome-stable dbus-x11 packagekit-gtk3-module libcanberra-gtk-module -y

COPY hosts /tmp/

RUN cat /tmp/hosts >> /etc/hosts
RUN apt-get install -y telnet
RUN service dbus start
RUN chmod -R 777 /var/run/dbus
RUN chmod -R 777 /run/dbus
RUN ln -s /run /var/run
RUN ln -s /run/lock /var/lock

RUN chmod 777 /run/dbus/pid
RUN chmod 777 /run/dbus/system_bus_socket
RUN chmod 777 /var/run/dbus/pid
RUN chmod 777 /var/run/dbus/system_bus_socket

RUN echo '#!/bin/sh' > /home/developer/start.sh
RUN echo 'cat /tmp/hosts >> /etc/hosts' >> /home/developer/start.sh
RUN echo '/usr/bin/google-chrome ---lxc-conf --cap-add=CAP_SYS_ADMIN' >> /home/developer/start.sh

RUN chmod +x /home/developer/start.sh

USER developer
ENV HOME /home/developer
CMD /usr/bin/google-chrome --cap-add=CAP_SYS_ADMIN
