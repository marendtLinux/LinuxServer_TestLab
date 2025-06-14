# LinuxServer_TestLab

This repository serves as a personal test lab to demonstrate and document my growing skills in Linux system administration.

It includes hands-on exercises, configuration examples, and small projects related to topics such as Bash scripting, Databases, Docker, Ansible, and Linux security.

I'm continuously expanding and refining this lab as part of my ongoing learning journey.

## Contents

### 🔧 Bash Scripting
- [**bash-scripting/**](./control_host/bash/)  
  - [Fail2Ban installer script](./control_host/bash/install_fail2ban/install_fail2ban.sh) for Debian-based systems  
  - [Fail2Ban deploy script](./control_host/bash/install_fail2ban/deploy_and-test_fail2ban.sh) – copies and runs the installer remotely  
  - [Bash script template generator](./control_host/bash/utilities/create_bashscript.sh)

### 🐳 Docker
- [**docker/**](./container)  
  - [MariaDB with `docker-compose`](./container/mariadb/compose.yaml) – Simple setup and usage

### 🤖 Ansible
- [**ansible/**](./control_host/ansible/)  
  - [Update playbook](./control_host/ansible/playbooks/update_packages.yml) for Debian- and RHEL-based distros  
  - [Fail2Ban install/configure playbook](./control_host/ansible/playbooks/fail2ban.yml) for both Debian and RHEL families
  - [MariaDB with docker compose, deployed with Ansible](./control_host/ansible/playbooks/mariadb/) 
  - [Nginx with docker compose, using SSL with self-signed certificates, deployed with Ansible](./control_host/ansible/playbooks/nginx/) 
  
### 🛡️ Firewall
- [**firewall/**](./control_host/bash/firewall/)  
  - [Basic iptables firewall script](./control_host/bash/firewall/iptables_config.sh) – A Bash script to configure a basic firewall with iptables  
  
### 📘 Guides & Documentation
- [**docs/**](./doc)  
  - [Set up MariaDB replication](./doc/db/mariaDB/setup_replication.md) – step-by-step instructions  
  - [Manual Fail2Ban configuration](./doc/security_and_hardening/fail2ban.md)  
  - [Disable SSH root login](./doc/security_and_hardening/ssh_disable_root_login.md)

### ⚙️ Configuration Files
- [**config-files/**](./server/)  
  - [Fail2Ban config files](./server/shared_config/etc/fail2ban/jail.d/customisation.local/)  
  - [MariaDB replication config](./server/server_specific/Server1/etc/mysql/my.cnf/)

### 🧳 SecurePortActivator
- 🔗 [**SecurePortActivator Repository**](https://github.com/marendtLinux/SecurePortActivator)  
  - A security-focused project to control port access based on user login status on a remote Linux server  
  - The goal: Only allow access to specific ports (e.g., 443, 3306 ) **after** a user has authenticated  
  - Uses login hooks (e.g., `pam_exec`), firewall rules (`iptables` or `nftables`), and custom scripts  
  - Potential use cases: secure ports for servers in developing stage, where the underlying application (e.g. apache) is not yet secure 
  - 👉 This project is maintained in a **separate repository** for better modularity and version control.

---

