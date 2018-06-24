netstat -lntp | grep -q '0\.0\.0\.0:9091' || exit 1
curl -L 'https://api.ipify.org' || exit 1
