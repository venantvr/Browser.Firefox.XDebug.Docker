FROM ubuntu:17.04

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    # echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    # chmod 0440 /etc/sudoers.d/developer && \
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

# RUN mkdir /var/run/dbus/
# RUN touch /var/run/dbus/system_bus_socket

RUN service dbus start
# RUN dbus-daemon --system

RUN chmod -R 777 /var/run/dbus
RUN chmod -R 777 /run/dbus

RUN ln -s /run /var/run
RUN ln -s /run/lock /var/lock
# RUN ln -s /run/dbus/pid /var/run/dbus/pid
# RUN ln -s /run/dbus/system_bus_socket /var/run/dbus/system_bus_socket

RUN chmod 777 /run/dbus/pid
RUN chmod 777 /run/dbus/system_bus_socket
RUN chmod 777 /var/run/dbus/pid
RUN chmod 777 /var/run/dbus/system_bus_socket

RUN echo '#!/bin/sh' > /home/developer/start.sh
RUN echo 'cat /tmp/hosts >> /etc/hosts' >> /home/developer/start.sh
# RUN echo 'mkdir /var/run/dbus' >> /home/developer/start.sh
# RUN echo 'service dbus start' >> /home/developer/start.sh
# RUN echo 'dbus-daemon --system' >> /home/developer/start.sh
RUN echo '/usr/bin/google-chrome ---lxc-conf --cap-add=CAP_SYS_ADMIN' >> /home/developer/start.sh

RUN chmod +x /home/developer/start.sh
# RUN /home/developer/start.sh

# RUN apt-get install -y ip

USER developer
ENV HOME /home/developer

# EXPOSE 9000

CMD /usr/bin/google-chrome --cap-add=CAP_SYS_ADMIN
