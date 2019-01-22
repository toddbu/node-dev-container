FROM ubuntu:18.04
MAINTAINER Todd Buiten <spam@buiten.com>

# Update the base system
RUN apt-get update && apt-get -y upgrade

# Install samba and supervisord
RUN apt-get install -y bash bash-completion vim sudo nodejs npm git tar gzip less make g++ linux-headers-generic curl docker openssh-server samba supervisor
RUN apt-get clean

# Change the default port for SSH from 22 to 2223
RUN sed -i 's/#Port 22/Port 2223/g' /etc/ssh/sshd_config; \
 ssh-keygen -A

# Copy config files for samba and ssh into supervisord
COPY samba.conf /etc/supervisor/conf.d/
COPY ssh.conf /etc/supervisor/conf.d/
COPY smb.conf /etc/samba/
RUN mkdir -p /var/run/sshd

# Add a non-root user and group called "dev" with gid/uid set to 1000
RUN adduser --uid 1000 --shell /bin/bash --disabled-password dev
RUN echo "dev123!\ndev123!" | passwd dev

# Add a few things for the "dev" user
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev;\
 chmod 660 /etc/sudoers.d/dev
COPY git-setup /home/dev/
RUN chown dev.dev /home/dev/git-setup;\
 chmod 770 /home/dev/git-setup
RUN addgroup --gid 998 i2c;\
 usermod -a --groups i2c dev

# Create a new samba user
RUN echo "sambapwd\nsambapwd" | smbpasswd -a -s -c /etc/samba/smb.conf dev

# Volume mappings
VOLUME /home/dev

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd) and sshd port 2223
EXPOSE 137/udp 138/udp 139 445 2223

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
