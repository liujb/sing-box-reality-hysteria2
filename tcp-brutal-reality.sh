#!/bin/bash

# 延迟打字
print_with_delay() {
    text="$1"
    delay="$2"
    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# 自定义字体彩色，read 函数
red() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
green() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
yellow() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色

#信息提示
show_notice() {
    local message="$1"

    local green_bg="\e[48;5;34m"
    local white_fg="\e[97m"
    local reset="\e[0m"

    echo -e "${green_bg}${white_fg}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
    echo -e "${white_fg}┃${reset}                                                                                             "
    echo -e "${white_fg}┃${reset}                                   ${message}                                                "
    echo -e "${white_fg}┃${reset}                                                                                             "
    echo -e "${green_bg}${white_fg}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
}

# 作者介绍
print_with_delay "Reality Grpc by 绵阿羊" 0.03
echo ""
echo ""

# 安装依赖
install_base(){
  # 安装qrencode
  local packages=("qrencode")
  for package in "${packages[@]}"; do
    if ! command -v "$package" &> /dev/null; then
      echo "正在安装 $package..."
      if [ -n "$(command -v apt)" ]; then
        sudo apt update > /dev/null 2>&1
        sudo apt install -y "$package" > /dev/null 2>&1
      elif [ -n "$(command -v yum)" ]; then
        sudo yum install -y "$package"
      elif [ -n "$(command -v dnf)" ]; then
        sudo dnf install -y "$package"
      else
        echo "无法安装 $package。请手动安装，并重新运行脚本。"
        exit 1
      fi
      echo "$package 已安装。"
    else
      echo "$package 已经安装。"
    fi
  done
}
# 创建快捷方式
create_shortcut() {
  cat > /root/sbox/mianyang.sh << EOF
#!/usr/bin/env bash
bash <(curl -fsSL https://github.com/vveg26/sing-box-reality-hysteria2/raw/main/tcp-brutal-reality.sh) \$1
EOF
  chmod +x /root/sbox/mianyang.sh
  ln -sf /root/sbox/mianyang.sh /usr/bin/mianyang

}
# 下载cloudflared和sb
download_singbox(){
  arch=$(uname -m)
  echo "Architecture: $arch"
  # Map architecture names
  case ${arch} in
      x86_64)
          arch="amd64"
          ;;
      aarch64)
          arch="arm64"
          ;;
      armv7l)
          arch="armv7"
          ;;
  esac
  # Fetch the latest (including pre-releases) release version number from GitHub API
  # 正式版
  #latest_version_tag=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases" | grep -Po '"tag_name": "\K.*?(?=")' | head -n 1)
  #beta版本
  latest_version_tag=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases" | grep -Po '"tag_name": "\K.*?(?=")' | sort -V | tail -n 1)
  latest_version=${latest_version_tag#v}  # Remove 'v' prefix from version number
  echo "Latest version: $latest_version"
  # Detect server architecture
  # Prepare package names
  package_name="sing-box-${latest_version}-linux-${arch}"
  # Prepare download URL
  url="https://github.com/SagerNet/sing-box/releases/download/${latest_version_tag}/${package_name}.tar.gz"
  # Download the latest release package (.tar.gz) from GitHub
  curl -sLo "/root/${package_name}.tar.gz" "$url"

  # Extract the package and move the binary to /root
  tar -xzf "/root/${package_name}.tar.gz" -C /root
  mv "/root/${package_name}/sing-box" /root/sbox

  # Cleanup the package
  rm -r "/root/${package_name}.tar.gz" "/root/${package_name}"

  # Set the permissions
  chown root:root /root/sbox/sing-box
  chmod +x /root/sbox/sing-box
}

# client configuration
show_client_configuration() {

  # 获取当前ip
  server_ip=$(grep -o "SERVER_IP='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
  
  # reality
  # reality当前端口
  reality_port=$(grep -o "REALITY_PORT='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
  # 当前偷取的网站
  reality_server_name=$(grep -o "REALITY_SERVER_NAME='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
  # 当前reality uuid
  reality_uuid=$(grep -o "REALITY_UUID='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
  # 获取公钥
  public_key=$(grep -o "PUBLIC_KEY='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
  # 获取short_id
  short_id=$(grep -o "SHORT_ID='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')

  brutal_up=$(grep -o "BRUTAL_UP='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')


show_notice "sing-box客户端配置参数"
cat << EOF
{
  "log": {
    "level": "debug",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "proxyDns",
        "address": "8.8.8.8",
        "detour": "proxy"
      },
      {
        "tag": "localDns",
        "address": "https://223.5.5.5/dns-query",
        "detour": "direct"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      },
      {
        "tag": "remote",
        "address": "fakeip"
      }
    ],
    "rules": [
      {
        "domain": [
          "ghproxy.com",
          "cdn.jsdelivr.net",
          "testingcf.jsdelivr.net"
        ],
        "server": "localDns"
      },
      {
        "geosite": "category-ads-all",
        "server": "block"
      },
      {
        "outbound": "any",
        "server": "localDns",
        "disable_cache": true
      },
      {
        "geosite": "cn",
        "server": "localDns"
      },
      {
        "clash_mode": "direct",
        "server": "localDns"
      },
      {
        "clash_mode": "global",
        "server": "proxyDns"
      },
      {
        "geosite": "geolocation-!cn",
        "server": "proxyDns"
      },
      {
        "query_type": [
          "A",
          "AAAA"
        ],
        "server": "remote"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/15",
      "inet6_range": "fc00::/18"
    },
    "independent_cache": true,
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "type": "tun",
      "inet4_address": "172.19.0.1/30",
      "mtu": 9000,
      "auto_route": true,
      "strict_route": true,
      "sniff": true,
      "endpoint_independent_nat": false,
      "stack": "system",
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "127.0.0.1",
          "server_port": 2080
        }
      }
    },
    {
      "type": "mixed",
      "listen": "127.0.0.1",
      "listen_port": 2080,
      "sniff": true,
      "users": []
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "auto",
        "direct",
        "sing-box-reality-brutal"
      ]
    },
    {
      "type": "vless",
      "tag": "sing-box-reality-brutal",
      "uuid": "$reality_uuid",
      "packet_encoding": "xudp",
      "server": "$server_ip",
      "server_port": $reality_port,
      "flow": "",
      "tls": {
        "enabled": true,
        "server_name": "$reality_server_name",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": true,
          "public_key": "$public_key",
          "short_id": "$short_id"
        }
      },
    "multiplex": {
        "enabled": true,
        "protocol": "h2mux",
        "max_connections": 1,
        "min_streams": 4,
        "padding": true,
        "brutal": {
            "enabled": true,
            "up_mbps": 50, //上行速度，windows，macos不会生效所以可随便写
            "down_mbps": $brutal_up //下行速度，对应服务器的下行速度，当然可自行修改
        }
    }
    },
    {
      "tag": "direct",
      "type": "direct"
    },
    {
      "tag": "block",
      "type": "block"
    },
    {
      "tag": "dns-out",
      "type": "dns"
    },
    {
      "tag": "auto",
      "type": "urltest",
      "outbounds": [
        "sing-box-reality-brutal"
      ],
      "url": "http://www.gstatic.com/generate_204",
      "interval": "1m",
      "tolerance": 50
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "proxy",
    "geoip": {
      "download_url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.db",
      "download_detour": "direct"
    },
    "geosite": {
      "download_url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.db",
      "download_detour": "direct"
    },
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "network": "udp",
        "port": 443,
        "outbound": "block"
      },
      {
        "geosite": "category-ads-all",
        "outbound": "block"
      },
      {
        "clash_mode": "direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "global",
        "outbound": "proxy"
      },
      {
        "domain": [
          "clash.razord.top",
          "yacd.metacubex.one",
          "yacd.haishan.me",
          "d.metacubex.one"
        ],
        "outbound": "direct"
      },
      {
        "geosite": "geolocation-!cn",
        "outbound": "proxy"
      },
      {
        "geoip": [
          "private",
          "cn"
        ],
        "outbound": "direct"
      },
      {
        "geosite": "cn",
        "outbound": "direct"
      }
    ]
  },
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "external_ui_download_url": "",
      "external_ui_download_detour": "",
      "external_ui": "ui",
      "secret": "",
      "default_mode": "rule",
      "store_selected": true,
      "cache_file": "",
      "cache_id": ""
    }
  }
}
EOF

}

#enable bbr
enable_bbr() {
    # temporary workaround for installing bbr
    bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
    echo ""
}
#修改sb
modify_singbox() {
    #modifying reality configuration
    show_notice "开始修改reality端口号和域名"
    reality_current_port=$(grep -o "REALITY_PORT='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
    while true; do
        read -p "请输入想要修改的端口号 (当前端口号为 $reality_current_port): " reality_port
        reality_port=${reality_port:-$reality_current_port}
        if [ "$reality_port" -eq "$reality_current_port" ]; then
            break
        fi
        if ss -tuln | grep -q ":$reality_port\b"; then
            echo "端口 $reality_port 已经被占用，请选择其他端口。"
        else
            break
        fi
    done
    reality_current_server_name=$(grep -o "REALITY_SERVER_NAME='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
    read -p "请输入想要偷取的域名 (当前域名为 $reality_current_server_name): " reality_server_name
    reality_server_name=${reality_server_name:-$reality_current_server_name}
    echo ""

    current_up=$(grep -o "BRUTAL_UP='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
    read -p "请输入上行带宽up，对应客户端下行带宽 (当前为 $current_up): " brutal_up
    brutal_up=${brutal_up:-$current_up}
    current_down=$(grep -o "BRUTAL_DOWN='[^']*'" /root/sbox/config | awk -F"'" '{print $2}')
    read -p "请输入下行带宽down (当前为 $current_down): " brutal_down
    brutal_down=${brutal_down:-$current_down}
    echo ""


    # 修改sing-box
    sed -i -e "/\"listen_port\":/s/[0-9]\+/$reality_port/" \
            -e "s/\"server_name\": *\"[^\"]*\"/\"server_name\": \"$reality_server_name\"/" \
            -e "s/\"server\": *\"[^\"]*\"/\"server\": \"$reality_server_name\"/" /root/sbox/sbconfig_server.json


    sed -i -e "/\"up_mbps\":/s/[0-9]\+/$brutal_up/" \
          -e "/\"down_mbps\":/s/[0-9]\+/$brutal_down/" /root/sbox/sbconfig_server.json


    #修改config
    sed -i "s/REALITY_PORT='[^']*'/REALITY_PORT='$reality_port'/" /root/sbox/config
    sed -i "s/REALITY_SERVER_NAME='[^']*'/REALITY_SERVER_NAME='$reality_server_name'/" /root/sbox/config
    sed -i "s/BRUTAL_UP='[^']*'/BRUTAL_UP='$brutal_up'/" /root/sbox/config
    sed -i "s/BRUTAL_DOWN='[^']*'/BRUTAL_DOWN='$brutal_down'/" /root/sbox/config
    # Restart sing-box service
    systemctl restart sing-box
}

uninstall_singbox() {
    # Stop and disable services
    systemctl stop sing-box 
    systemctl disable sing-box  > /dev/null 2>&1

    # Remove service files
    rm -f /etc/systemd/system/sing-box.service

    # Remove configuration and executable files
    rm -f /root/sbox/sbconfig_server.json
    rm -f /root/sbox/sing-box
    rm -f /root/sbox/mianyang.sh
    rm -f /usr/bin/mianyang
    rm -f /root/sbox/config

    # Remove directories
    rm -rf /root/sbox/

    echo "卸载完成"
}

# install_base
install_brutal(){
  bash <(curl -fsSL https://tcp.hy2.sh/)
}

# Check if reality.json, sing-box, and sing-box.service already exist
if [ -f "/root/sbox/sbconfig_server.json" ] && [ -f "/root/sbox/config" ] && [ -f "/root/sbox/mianyang.sh" ] && [ -f "/usr/bin/mianyang" ] && [ -f "/root/sbox/sing-box" ] && [ -f "/etc/systemd/system/sing-box.service" ]; then

    echo "sing-box-reality已经安装"
    echo ""
    echo "请选择选项:"
    echo ""
    echo "1. 重新安装"
    echo "2. 修改配置"
    echo "3. 显示客户端配置"
    echo "4. 卸载"
    echo "5. 更新sing-box内核"
    echo "6. 一键开启bbr"
    echo "7. 重启sing-box"
    echo ""
    read -p "Enter your choice (1-7): " choice

    case $choice in
      1)
          show_notice "开始卸载..."
          # Uninstall previous installation
          uninstall_singbox
        ;;
      2)
          #修改sb
          modify_singbox
          # show client configuration
          show_client_configuration
          exit 0
        ;;
      3)  
          # show client configuration
          show_client_configuration
          exit 0
      ;;	
      4)
          uninstall_singbox
          exit 0
          ;;
      5)
          show_notice "更新 Sing-box..."
          download_singbox
          # Check configuration and start the service
          if /root/sbox/sing-box check -c /root/sbox/sbconfig_server.json; then
              echo "Configuration checked successfully. Starting sing-box service..."
              systemctl restart sing-box
          fi
          echo ""  
          exit 0
          ;;
      6)
          enable_bbr
          exit 0
          ;;
      7)
          systemctl restart sing-box
          echo "重启完成"
	  exit 0
          ;;
      *)
          echo "Invalid choice. Exiting."
          exit 1
          ;;
	esac
	fi

  
install_brutal

mkdir -p "/root/sbox/"

download_singbox

# reality
red "开始配置Reality"
echo ""
# Generate key pair
echo "自动生成基本参数"
echo ""
key_pair=$(/root/sbox/sing-box generate reality-keypair)
echo "Key pair生成完成"
echo ""

# Extract private key and public key
private_key=$(echo "$key_pair" | awk '/PrivateKey/ {print $2}' | tr -d '"')
public_key=$(echo "$key_pair" | awk '/PublicKey/ {print $2}' | tr -d '"')

# Generate necessary values
reality_uuid=$(/root/sbox/sing-box generate uuid)
short_id=$(/root/sbox/sing-box generate rand --hex 8)
echo "uuid和短id 生成完成"
echo ""
# Ask for listen port
while true; do
    read -p "请输入Reality端口号 (default: 443): " reality_port
    reality_port=${reality_port:-443}

    # 检测端口是否被占用
    if ss -tuln | grep -q ":$reality_port\b"; then
        echo "端口 $reality_port 已经被占用，请重新输入。"
    else
        break
    fi
done
echo ""
# Ask for server name (sni)
read -p "请输入想要偷取的域名,需要支持tls1.3 (default: itunes.apple.com): " reality_server_name
reality_server_name=${reality_server_name:-itunes.apple.com}
echo ""
read -p "请输入上行up带宽，对应客户端的下行带宽 (default: 100): " brutal_up
brutal_up=${brutal_up:-100}
read -p "请输入下行down带宽 (default: 1000): " brutal_down
brutal_down=${brutal_down:-1000}

#ip地址
server_ip=$(curl -s4m8 ip.sb -k) || server_ip=$(curl -s6m8 ip.sb -k)

#config配置文件
cat > /root/sbox/config <<EOF

# VPS ip
SERVER_IP='$server_ip'
# Singbox
# Reality
PRIVATE_KEY='$private_key'
PUBLIC_KEY='$public_key'
SHORT_ID='$short_id'
REALITY_UUID='$reality_uuid'
REALITY_PORT='$reality_port'
REALITY_SERVER_NAME='$reality_server_name'
# Brutal
BRUTAL_UP='$brutal_up'
BRUTAL_DOWN='$brutal_down'
EOF


# sbox配置文件
cat > /root/sbox/sbconfig_server.json << EOF
{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": $reality_port,
      "users": [
        {
          "uuid": "$reality_uuid",
          "flow": ""
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "$reality_server_name",
        "reality": {
          "enabled": true,
          "handshake": {
            "server": "$reality_server_name",
            "server_port": 443
          },
          "private_key": "$private_key",
          "short_id": ["$short_id"]
        }
      },
        "multiplex": {
            "enabled": true,
            "padding": true,
            "brutal": {
                "enabled": true,
                "up_mbps": $brutal_up,
                "down_mbps": $brutal_down
            }
        }}
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ]
}
EOF





# Create sing-box.service
cat > /etc/systemd/system/sing-box.service <<EOF
[Unit]
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStart=/root/sbox/sing-box run -c /root/sbox/sbconfig_server.json
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF


# Check configuration and start the service
if /root/sbox/sing-box check -c /root/sbox/sbconfig_server.json; then
    echo "Configuration checked successfully. Starting sing-box service..."
    systemctl daemon-reload
    systemctl enable sing-box > /dev/null 2>&1
    systemctl start sing-box
    systemctl restart sing-box
    create_shortcut
    show_client_configuration


else
    echo "Error in configuration. Aborting"
fi