FROM alpine:3.7
MAINTAINER Ollie Hughes <ohughes@pivotal.io>

RUN apk add -U bash curl tar wget vim rsync gnupg netcat-openbsd build-base ca-certificates zsh git openssh-client shadow go less nmap nmap-scripts tcpdump bind-tools jq
RUN rm -f /tmp/* /etc/apk/cache/*

RUN git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh \
&& echo 'export ZSH=$HOME/.oh-my-zsh' >> /root/.zshrc \
&& echo 'ZSH_THEME="sunaku"' >> /root/.zshrc \
&& echo 'plugins=(git history-substring-search vi-mode)' >> /root/.zshrc \
&& echo 'source $ZSH/oh-my-zsh.sh' >> /root/.zshrc \
&& echo 'export TERM=xterm-256color' >> /root/.zshrc 

RUN wget https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip \
&& unzip consul_1.0.6_linux_amd64.zip \
&& mv consul /usr/local/bin

RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/fzf \
 && /root/fzf/install --all 

RUN wget -O /tmp/vault.zip "https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip" \
  && unzip -d /usr/local/bin /tmp/vault.zip \
  && chmod 755 /usr/local/bin/vault \
  && rm /tmp/vault.zip
RUN chsh -s /bin/zsh
ENV SHELL /bin/zsh
ENTRYPOINT /bin/zsh
