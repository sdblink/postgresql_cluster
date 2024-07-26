FROM almalinux:9

# Installer les dépendances de base
RUN yum -y install epel-release && \
    yum -y install systemd systemd-libs python3 python3-pip openssh-server sudo gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make ncurses sshpass ansible procps-ng && \
    ssh-keygen -A && \
    echo "root:password" | chpasswd && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    yum clean all

# Installer Python 3.10
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz && \
    tar xzf Python-3.10.4.tgz && \
    cd Python-3.10.4 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python3.10 && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3.10

# Copier les fichiers de configuration et installer les dépendances
COPY requirements.txt /opt/project/requirements.txt
COPY . /opt/project/
RUN pip3.10 install -r /opt/project/requirements.txt && \
    if [ -f /opt/project/requirements-dev.txt ]; then pip3.10 install -r /opt/project/requirements-dev.txt; fi

# Ajuster les permissions du répertoire du projet
RUN chmod -R 755 /opt/project

WORKDIR /opt/project

# Activer systemd dans le conteneur
ENV container docker
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]

# Exposer le port SSH
EXPOSE 22
