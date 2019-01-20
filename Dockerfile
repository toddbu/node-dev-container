FROM ubuntu:18:04
MAINTAINER Todd Buiten <spam@buiten.com>

# Update the base system
RUN apt-get update && apt-get upgrade

# Install samba and supervisord
RUN apt-get install bash bash-completion sudo nodejs npm git tar gzip less make g++ linux-headers curl bind-tools docker openssh samba samba-common-tools supervisor && apt-cache clean

# Change the default port for SSH from 22 to 2223
RUN sed -i 's/#Port 22/Port 2223/g' /etc/ssh/sshd_config; \
 ssh-keygen -A

# Copy config files for samba and supervisord
COPY samba.ini /etc/supervisor.d/
COPY ssh.ini /etc/supervisor.d/
COPY smb.conf /etc/samba/

# Add a non-root user and group called "dev" gid/uid set to 1000
RUN addgroup -g 1000 dev && adduser -D -G dev -u 1000 -s /bin/bash dev
RUN echo -e "dev123!\ndev123!" | passwd dev

# Add a few things for the "dev" user
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev;\
 chmod 660 /etc/sudoers.d/dev
COPY git-setup /home/dev/
RUN chown dev.dev /home/dev/git-setup;\
 chmod 770 /home/dev/git-setup
RUN addgroup -g 998 i2c;\
 usermod -a -G i2c dev

# Create a new samba user
RUN echo -e "sambapwd\nsambapwd\n" | smbpasswd -a -s -c /etc/samba/smb.conf dev

# Volume mappings
VOLUME /etc/supervisor.d /etc/ssh /etc/samba /home/dev

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd) and sshd port 2223
EXPOSE 137/udp 138/udp 139 445 2223

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
