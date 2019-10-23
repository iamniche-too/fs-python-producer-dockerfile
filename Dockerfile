FROM ubuntu:18.04 

# default to bash shell
#SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install --assume-yes ssh-client \
    docker.io \
    wget \
    python3-venv \
    python3-pip \
    git

RUN pip3 install --no-cache-dir --upgrade pip

# Download public key for github.com
RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com > /root/.ssh/known_hosts

ADD git-repo-key /root/.ssh/
RUN chmod 600 /root/.ssh/git-repo-key

# Clone repo from github
RUN eval "$(ssh-agent -s)" && ssh-add /root/.ssh/git-repo-key && \
  echo "Host * \r\n StrictHostKeyChecking no \r\n" >> /root/.ssh/config && \  
  echo "Host github.com Hostname ssh.github.com Port 443 \r\n" >> /root/.ssh/config && \
  git clone ssh://git@ssh.github.com/iamniche-too/fs-python /usr/local/fs-python

# install python
RUN python3 -m venv /usr/local/fs-python/env && . /usr/local/fs-python/env/bin/activate && \ 
  pip install --no-cache-dir -r /usr/local/fs-python/requirements.txt 

COPY start-producer.sh /tmp 
RUN chmod a+x /tmp/*.sh
RUN cp /tmp/start-producer.sh /usr/bin

VOLUME ["/kafka"]

ENTRYPOINT ["/bin/bash", "/usr/bin/start-producer.sh"]
