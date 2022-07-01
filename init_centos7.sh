#!/bin/bash

if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to run"
    exit 1
fi

platform=$(uname -i)
if [ $platform != "x86_64" ]; then
  echo "this script is only for 64bit Operating System !"
  exit 1
fi
echo "the platform is ok"
version=$(more /etc/redhat-release | awk '{print $4}' | awk -F'.' '{print $1}')
if [ $version != 7 ]; then
  echo "this script is only for CentOS 7 !"
  exit 1
fi

yum -y -q install wget sed tar unzip lrzsz sudo

if cat /etc/locale.conf | awk -F: '{print $1}' | grep 'en_US.UTF-8' 2>&1 > /dev/null; then
  echo -e "Lang has been \e[0;32m\033[1madded\e[m."
else
  sed -i s/LANG=.*$/LANG=\"en_US.UTF-8\"/ /etc/locale.conf
  echo -e "Set LANG en_US.UTF-8 ${DONE}."
fi

chmod +x /etc/rc.d/rc.local

echo never  > /sys/kernel/mm/redhat_transparent_hugepage/defrag
echo 262144 > /proc/sys/net/core/somaxconn

#定义变量
COLOR1="echo -e \E[1;33m"
COLOR2="echo -e \E[1;32m"
END="\E[0m"
FIREWALLD=$(systemctl is-enabled firewalld.service)
SELINUX=$(grep -v "^#" /etc/selinux/config | grep -i "selinux=" | awk -F= '{print $2}')
OS_VERSION=$(cat /etc/centos-release | awk -F' ' '{print $4}' | awk -F. '{print $1"."$2}')

echo "----修改时区----"
timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo "----修改字符编码----"
echo 'LANG="en_US.UTF-8"
SUPPORTED="zh_CN.GB18030:zh_CN:zh:en_US.UTF-8:en_US:en"
SYSFONT="latarcyrheb-sun16"' > /etc/locale.conf

#禁用Firewalld
disabled_firewalld() {
  if [ $FIREWALLD = disabled ]; then
    $COLOR1"Firewalld防火墙已禁用成功！"$END
  elif [ $FIREWALLD != disabled ]; then
    systemctl disable --now firewalld &> /dev/null && $COLOR2"Firewalld防火墙禁用成功！"$END
  fi
}

#禁用SELinux
disabled_selinux() {
  if [ $SELINUX = disabled ]; then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl stop postfix.service
    systemctl disable postfix.service
    $COLOR1"SELinux已禁用成功！"$END
  elif [ $SELINUX != disabled ]; then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl stop postfix.service
    systemctl disable postfix.service
    sed -i "s/$SELINUX/disabled/g" /etc/selinux/config && $COLOR2"SElinux禁用成功！"$END
  fi
}

# 优化ssh登录
# sed -ri 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# sed -ri 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# 修改网卡名称为统一为传统方式命名
# sed -ri '/CMDLINE/s#(.*)"#\1 net.ifnames=0"#' /etc/default/grub
# grub2-mkconfig -o /etc/grub2.cfg

#安装常用软件
install_packages() {
  yum list installed | grep ftp &> /dev/null
  if [ $? -eq 0 ]; then
    $COLOR1"常用软件已安装成功！"$END
  elif [ $? -ne 0 ]; then
    yum -y install vim net-tools httpd-tools lrzsz tree tmux man-pages strace redhat-lsb-core wget chrony psmisc man-pages zip unzip bzip2 tcpdump ftp rsync lsof &> /dev/null
    $COLOR2"常用软件安装成功！"$END
  fi
}

#配置EPEL源
config_epelrepo() {
  if [ $OS_VERSION = "7.9" ]; then
    yum repolist | grep '^epel' &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR1"EPEL源已配置成功！"$END
    elif [ $? -ne 0 ]; then
      mkdir /root/yum/ &> /dev/null
      mv /etc/yum.repos.d/* yum/ &> /dev/null
      wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo &> /dev/null
      wget -O /etc/yum.repos.d/CentOS7-Base-163.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo &> /dev/null
      yum clean all &> /dev/null
      yum makecache &> /dev/null
      yum install -y epel-release &> /dev/null
      wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo &> /dev/null
      yum clean all &> /dev/null
      yum makecache &> /dev/null
      yum repolist | grep '^epel' &> /dev/null
      [ $? -eq 0 ] && $COLOR2"EPEL源配置成功！"$END
    fi
  elif [ $OS_VERSION = "8.3" ]; then
    yum repolist | grep '^epel' &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR1"EPEL源已配置成功！"$END
    elif [ $? -ne 0 ]; then
      sed -i 's/mirrorlist/#mirrorlist/' /etc/yum.repos.d/CentOS-Linux-AppStream.repo
      sed -i 's/mirrorlist/#mirrorlist/' /etc/yum.repos.d/CentOS-Linux-BaseOS.repo
      sed -i 's/mirrorlist/#mirrorlist/' /etc/yum.repos.d/CentOS-Linux-Extras.repo
      echo 'baseurl=https://mirrors.aliyun.com/centos/$releasever/AppStream/$basearch/os/' >> /etc/yum.repos.d/CentOS-Linux-AppStream.repo
      echo 'baseurl=https://mirrors.aliyun.com/centos/$releasever/BaseOS/$basearch/os/' >> /etc/yum.repos.d/CentOS-Linux-BaseOS.repo
      echo 'baseurl=https://mirrors.aliyun.com/centos/$releasever/extras/$basearch/os/' >> /etc/yum.repos.d/CentOS-Linux-Extras.repo
      dnf -y install epel-release &> /dev/null
      dnf clean all &> /dev/null
      dnf makecache &> /dev/null
      yum repolist | grep '\<epel\>' &> /dev/null
      [ $? -eq 0 ] && $COLOR2"EPEL源配置成功！"$END

    fi
  fi
}

#配置时间同步
config_chrony() {
  if [ $OS_VERSION = "7.9" ]; then
    if grep qsyj /etc/chrony.conf &> /dev/null; then
      $COLOR1"时间同步已配置成功！"$END
    else
      sed -i '/^server.*/d' /etc/chrony.conf
      echo "server ntp.aliyun.com iburst" >> /etc/chrony.conf
      systemctl enabled --now chronyd &> /dev/null && systemctl restart chronyd &> /dev/null
      [ $? -eq 0 ] && $COLOR2"时间同步配置成功！"$END
    fi

  elif [ $OS_VERSION = "8.3" ]; then
    if grep qsyj /etc/chrony.conf &> /dev/null; then
      $COLOR1"时间同步已配置成功！"$END
    else
      sed -i '/^pool.*/d' /etc/chrony.conf &> /dev/null
      echo "server ntp.aliyun.com iburst" >> /etc/chrony.conf
      systemctl enabled --now chronyd &> /dev/null && systemctl restart chronyd &> /dev/null
      [ $? -eq 0 ] && $COLOR2"时间同步配置成功！"$END
    fi
  fi
}

#配置静态地址并修改网卡名称
config_network() {
  [ -f /etc/sysconfig/network-scripts/ifcfg-ens* ] && mv /etc/sysconfig/network-scripts/ifcfg-ens* /etc/sysconfig/network-scripts/ifcfg-eth0
  sed -i -e 's/.*NAME=.*/NAME=eth0/' -e 's/.*DEVICE=.*/DEVICE=eth0/' /etc/sysconfig/network-scripts/ifcfg-eth0
  grep static /etc/sysconfig/network-scripts/ifcfg-eth0 &> /dev/null
  if [ $? -eq 0 ]; then
    $COLOR1"IP地址已配置为静态地址！"$END
    ifconfig | grep eth0 &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR1"网卡名称已修改成功！"$END
    elif [ $? -ne 0 ]; then
      cp /etc/default/grub{,.bak}
      sed -i 's/quiet/quiet net.ifnames=0/' /etc/default/grub
      cp /boot/efi/EFI/centos/grub.cfg{,.bak} &> /dev/null
      if [ $? -eq 0 ]; then
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
      elif [ $? -ne 0 ]; then
        cp /boot/grub2/grub.cfg{,.bak}
        grub2-mkconfig -o /boot/grub2/grub.cfg
      fi
      $COLOR2"网卡名称修改成功！"$END
    fi

  elif [ $? -ne 0 ]; then
    sed -i 's/dhcp/static/' /etc/sysconfig/network-scripts/ifcfg-eth0 &> /dev/null
    echo "IPADDR=172.18.61.105
PREFIX=16
GATEWAY=172.18.1.1
DNS1=172.18.61.83
DNS2=172.18.61.84" >> /etc/sysconfig/network-scripts/ifcfg-eth0
    $COLOR2"IP地址成功配置为静态地址！"$END
    ifconfig | grep eth0 &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR1"网卡名称已修改成功！"$END
    elif [ $? -ne 0 ]; then
      cp /etc/default/grub{,.bak}
      sed -i 's/quiet/quiet net.ifnames=0/' /etc/default/grub
      cp /boot/efi/EFI/centos/grub.cfg{,.bak} &> /dev/null
      if [ $? -eq 0 ]; then
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
      elif [ $? -ne 0 ]; then
        cp /boot/grub2/grub.cfg{,.bak}
        grub2-mkconfig -o /boot/grub2/grub.cfg
      fi
      $COLOR2"网卡名称修改成功！"$END

    fi
  fi
}

#修改命令提示符颜色
config_terminal_color() {
  if [ $OS_VERSION = "7.9" ]; then
    echo 'PS1="\[\e[1;32m\][\u@\h \W]\\$\[\e[0m\]"' > /etc/profile.d/env-7.sh &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR2"命令提示符修改成功！"$END
    elif [ $? -ne 0 ]; then
      exit 0
    fi
  elif [ $OS_VERSION = "8.3" ]; then
    echo 'PS1="\[\e[1;36m\][\u@\h \W]\\$\[\e[0m\]"' > /etc/profile.d/env-8.sh &> /dev/null
    if [ $? -eq 0 ]; then
      $COLOR2"命令提示符修改成功！"$END
    elif [ $? -ne 0 ]; then
      exit 0
    fi
  fi
}

disabled_firewalld
disabled_selinux
install_packages
config_epelrepo
config_chrony
#config_network
config_terminal_color

###
cat << EOF > /etc/sysctl.conf

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

##决定检查过期多久邻居条目
net.ipv4.neigh.default.gc_stale_time=120

##使用arp_announce / arp_ignore解决ARP映射问题
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1

# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

#路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

#关闭sysrq功能
kernel.sysrq = 0

#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1

# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

#timewait的数量,默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

#每个网络接口接收数据包的速率比内核处理这些包的速率快时,允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144

#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800

#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 1

#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1

#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1

#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1

#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1

#当keepalive 起用的时候,TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30

#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024 65000

#修改防火墙表大小,默认65536
#net.netfilter.nf_conntrack_max=655350
#net.netfilter.nf_conntrack_tcp_timeout_established=1200

# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

##
kernel.printk = 5
kernel.threads-max = 1060863
fs.file-max = 5242880
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384

EOF
