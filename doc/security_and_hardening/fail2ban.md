## Introduction

Fail2ban is a useful tool for protecting a server against ssh-attacks. Fail2ban places a ban on ip-addresses, that
do a number of failed ssh-login attempts.

**Note:** You find a script that automatically deploys and tests fail2ban on a server  
at (control_host/bash/install_fail2ban/deploy_and-test_fail2ban.sh)

## Installation and testing of fail2ban

### 1. install fail2ban

install fail2ban

```bash
sudo apt install fail2ban
```

### 2. configure fail2ban

to configure it, you should create a customisation-file

```bash
touch /etc/fail2ban/jail.d/customisation.local
```

Now place the following configuration into this file:

```plaintext
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
action  = iptables[name=sshd, port=ssh]
bantime  = 3m
```

Now enable and restart the service

```bash
systemctl enable fail2ban

systemctl restart fail2ban
```

### 3. test fail2ban

In order to test the service, you should do invalid ssh-login attempts to the server:

```bash
invaliduser123@server-ip
```

While doing that, the client shows the number of failed attempts on the server.
Run this command on the server:

```bash
fail2ban-client status sshd
```

If you reached the number of invalid login-attempts configured in the variable maxretry in customisation.local, you should try a
ssh-login with valid credentials. You should see then a refused Connection. This should look like this example:


```bash
ssh: connect to host 111.0.0.1 port 22: Connection refused
```



