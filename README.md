# LinuxServer_TestLab

This repository serves as a personal test lab to demonstrate and document my growing skills in Linux system administration.

It includes hands-on exercises, configuration examples, and small projects related to topics such as Bash scripting, Databases, Docker, Ansible, and Linux security.

I'm continuously expanding and refining this lab as part of my ongoing learning journey.

## Contents

### 🔧 Bash Scripting
- [**bash-scripting/**](./control_host/bash/)  
  - [Fail2Ban installer script](./control_host/bash/install_fail2ban/install_fail2ban.sh) for Debian-based systems  
  - [Fail2Ban deploy script](./control_host/bash/install_fail2ban/deploy_and-test_fail2ban.sh) – copies and runs the installer remotely  
  - [Bash script template generator](./control_host/bash/utilities/create_bash_script.sh)

### 🐳 Docker
- [**docker/**](./container)  
  - [MariaDB with `docker-compose`](./container/mariadb/compose.yaml) – Simple setup and usage

### 🤖 Ansible
- [**ansible/**](./control_host/ansible/)  
  - [Update playbook](./control_host/ansible/playbooks/update_packages.yml) for Debian- and RHEL-based distros  
  - [Fail2Ban install/configure playbook](./control_host/ansible/playbooks/fail2ban.yml) for both Debian and RHEL families
  - [MariaDB with docker compose, deployed with Ansible](./control_host/ansible/playbooks/mariadb/) 

### 📘 Guides & Documentation
- [**docs/**](./doc)  
  - [Set up MariaDB replication](./doc/db/mariaDB/setup_replication.md) – step-by-step instructions  
  - [Manual Fail2Ban configuration](./doc/security_and_hardening/fail2ban.md)  
  - [Disable SSH root login](./doc/security_and_hardening/ssh_disable_root_login.md)

### ⚙️ Configuration Files
- [**config-files/**](./server/)  
  - [Fail2Ban config files](./server/shared_config/etc/fail2ban/jail.d/customisation.local/)  
  - [MariaDB replication config](./server/server_specific/Server1/etc/mysql/my.cnf/)

---

