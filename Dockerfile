FROM ubuntu:22.04
MAINTAINER Todd Buiten <spam@buiten.com>

# Update the base system
RUN apt-get update && apt-get -y upgrade

# Install tzdata non-interactively which should set us to UTC
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# Install samba and supervisord
RUN apt-get install -y bash bash-completion vim sudo git tar gzip less make g++ linux-headers-generic curl docker.io openssh-server samba smbclient netatalk supervisor python3-pip iputils-ping bind9-utils net-tools lsof dnsutils

# Install Node 16
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN apt-get install -y nodejs

# Clean up
RUN apt-get clean

# Change the default port for SSH from 22 to 2222
# RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config; \
RUN ssh-keygen -A;\
 mkdir -p /var/run/sshd

# Copy config files for supervisord defaults, samba, afp (netatalk), and ssh into supervisord
COPY supervisord.conf /etc/supervisor/conf.d/
COPY samba.conf /etc/supervisor/conf.d/
COPY netatalk.conf /etc/supervisor/conf.d/
COPY ssh.conf /etc/supervisor/conf.d/
COPY smb.conf /etc/samba/
COPY afp.conf /etc/netatalk/

# Add a non-root user and group called "dev" with gid/uid set to 1000
RUN adduser --uid 1000 --shell /bin/bash --disabled-password --gecos "" dev
RUN echo "dev123!\ndev123!" | passwd dev

# Add a few things for the "dev" user
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev;\
 chmod 440 /etc/sudoers.d/dev
COPY git-setup /home/dev/
RUN chown dev.dev /home/dev/git-setup;\
 chmod 770 /home/dev/git-setup
RUN addgroup --gid 998 i2c;\
 usermod -a --groups i2c dev

# Create a new samba user
RUN echo "sambapwd\nsambapwd" | smbpasswd -a -s -c /etc/samba/smb.conf dev

# Create a user for vagrant to manage the container
RUN adduser --uid 1001 --shell /bin/bash --disabled-password --gecos "" vagrant
RUN echo "vagrant\nvagrant" | passwd vagrant
RUN echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant.vagrant /home/vagrant/.ssh

# Volume mappings
VOLUME /home/dev

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd), afp port 548, sshd port 2222
EXPOSE 137/udp 138/udp 139 445 548 2222

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
