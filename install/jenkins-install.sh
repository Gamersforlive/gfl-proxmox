#!/usr/bin/env bash
# GFL Proxmox Scripts - Jenkins installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Java 21"
$STD apt-get install -y fontconfig openjdk-21-jre-headless
msg_ok "Installed $(java -version 2>&1 | head -n1)"

msg_info "Adding the Jenkins repository"
add_repo jenkins https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key https://pkg.jenkins.io/debian-stable binary/ ""
msg_ok "Added the Jenkins repository"

msg_info "Installing Jenkins"
$STD apt-get install -y jenkins git
systemctl enable -q --now jenkins
for i in $(seq 1 60); do
  if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then break; fi
  sleep 2
done
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  save_creds "Jenkins" "first-start unlock password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
  msg_ok "Installed Jenkins (unlock password in /root/jenkins.creds)"
else
  msg_warn "Jenkins is still starting; the unlock password will be in /var/lib/jenkins/secrets/initialAdminPassword"
fi

motd_ssh
customize
cleanup_lxc
