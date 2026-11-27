#!/bin/bash
set -e

echo "=============================="
echo " Java + Docker + Jenkins Setup"
echo "=============================="

# --- Java ---
sudo apt update -y
sudo apt install -y openjdk-21-jdk wget curl ca-certificates gnupg
java -version

# --- Docker ---
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# --- Jenkins ---
sudo mkdir -p /opt/jenkins
sudo chown -R "$USER":"$USER" /opt/jenkins
cd /opt/jenkins

if [ ! -f jenkins.war ]; then
  echo "Downloading Jenkins WAR (LTS)..."
  wget -O jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
fi

# --- systemd service ---
sudo tee /etc/systemd/system/jenkins-war.service > /dev/null <<EOF
[Unit]
Description=Jenkins (WAR)
After=network.target

[Service]
User=$USER
Environment=JENKINS_HOME=/opt/jenkins/home
ExecStart=/usr/bin/java -Djava.net.preferIPv4Stack=true -jar /opt/jenkins/jenkins.war --httpPort=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /opt/jenkins/home
sudo systemctl daemon-reload
sudo systemctl enable --now jenkins-war

echo "=============================="
echo " Done!"
echo " URL: http://<SERVER-IP>:8080"
echo " Admin password:"
echo "   cat /opt/jenkins/home/secrets/initialAdminPassword"
echo " Logs: journalctl -u jenkins-war -f"
echo " NOTE: log out and back in so 'docker' works without sudo"
echo "=============================="

