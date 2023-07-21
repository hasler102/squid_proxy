#!/bin/bash
port="1$(cat /dev/urandom | tr -dc '0-9' | fold -w 4 | head -n 1)"
log="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 3 | head -n 1)$(cat /dev/urandom | tr -dc '0-9' | fold -w 3 | head -n 1)"
pass="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 3 | head -n 1)$(cat /dev/urandom | tr -dc '0-9' | fold -w 3 | head -n 1)"
ip=$(curl ipinfo.io/json | grep -oP '(?<="ip": ")[^"]*')
channel_id=$(awk '/channel_id:/ {print $NF}' config);
tg_bot_token=$(awk '/tg_bot_token:/ {print $NF}' config);
proxy_name=$(awk '/proxy_name:/ {print $NF}' config);

sudo apt install squid apache2-utils -y
sudo curl -o /etc/squid/squid.conf https://raw.githubusercontent.com/AndreyHU1/squid_proxy/main/squid.conf
sed -i s/"http_port 18763"/"http_port $port"/ /etc/squid/squid.conf
sudo htpasswd -b -c /etc/squid/passwd "$log" "$pass"

echo "port: $port"
echo "log: $log"
echo "pass: $pass"
echo "ip: $ip"
systemctl restart squid

curl -F chat_id="$channel_id" -F text="✅ Proxy $proxy_name  $ip  $port  $log  $pass" https://api.telegram.org/bot"$tg_bot_token"/sendMessage
