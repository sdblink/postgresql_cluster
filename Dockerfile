FROM almalinux:latest

# Installer les dépendances de base
RUN yum -y install openssh-server sudo gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make ncurses && \
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

WORKDIR /opt/project

# Exposer le port SSH
EXPOSE 22

# Commande pour démarrer le service SSH
CMD ["/usr/sbin/sshd", "-D"]

