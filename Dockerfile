FROM python:3.12-bookworm

# 避免互動提示 & 關閉 pip 更新提示
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# ================================
# 系統環境與常用工具
# ================================
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
 && echo "Asia/Taipei" > /etc/timezone \
 && apt update -qq \
 && apt install -y -qq --no-install-recommends \
      vim nano curl telnet net-tools lsb-release less wget openssh-server \
      libpq-dev gnupg ca-certificates tzdata cron sudo \
      ffmpeg sox libsndfile1 \
      libopencv-dev \
      libchromaprint-tools \
 && rm -rf /var/lib/apt/lists/*
 
# ================================
# Python 套件
# ================================
RUN python -m pip install --upgrade --no-cache-dir pip \
 && pip install --no-cache-dir pipdeptree
    
# ================================
# 全域 Bash 設定 (for 所有使用者)
# ================================
RUN { \
  echo "# ===== Global Bash Configuration ====="; \
  echo ""; \
  echo "# 彩色化 ls 與人性化顯示"; \
  echo "alias ls='ls --color=auto'"; \
  echo "alias ll='ls -alhF --color=auto'"; \
  echo "alias la='ls -A --color=auto'"; \
  echo ""; \
  echo "# 彩色化 grep、egrep、fgrep"; \
  echo "alias grep='grep --color=auto'"; \
  echo "alias egrep='egrep --color=auto'"; \
  echo "alias fgrep='fgrep --color=auto'"; \
  echo ""; \
  echo "# 常用系統檢視指令"; \
  echo "alias df='df -h'"; \
  echo "alias du='du -sh'"; \
  echo "alias free='free -h'"; \
  echo ""; \
  echo "# 常用導航與清理指令"; \
  echo "alias cls='clear'"; \
  echo "alias cd..='cd ..'"; \
  echo ""; \
  echo "# 提示目前登入者與路徑（彩色 PS1）"; \
  echo 'export PS1="\\[\\e[0;36m\\]\\u@\\h:\\[\\e[0;33m\\]\\w\\[\\e[0m\\]\\$ "'; \
} >> /etc/bash.bashrc

# ================================
# SSH 設定
# ================================
RUN mkdir /var/run/sshd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && echo 'UsePAM no' >> /etc/ssh/sshd_config \
 && ssh-keygen -A

# ================================
# Vim 設定
# ================================
ADD vimrc_shared /etc/vimrc_shared
RUN ln -sf /etc/vimrc_shared /root/.vimrc 

# ================================
# Port 與環境變數
# ================================
EXPOSE 22 8888

# ================================
# 預設工作目錄
# ================================
WORKDIR /usr/src/app