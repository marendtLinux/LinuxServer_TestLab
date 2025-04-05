
## Introduction
The direct root login via SSH represents a significant security risk. If this is activated, a potential attacker can directly attempt to log in as root. Deactivating the root login increases security, as an attacker must also guess the user name to gain access.

## Instructions for deactivating
### 1. create a new user

**ATTENTION:** creating a username that is easy to guess is not recommended. If an SSH key falls into the wrong hands and the root login does not work, the user name must be guessed. A simple name such as user1, admin1 etc. is therefore a security risk. Choose a harder to guess name like: adm1n68545

Creating a new user, e.g.  `adm1n68545`.

```bash
sudo adduser adm1n68545
```

### 2. Set authorizations for `adm1n68545`
Allow `adm1n68545` to execute root commands with `sudo`. To do this, `adm1n68545` can be added to the `sudo` group or entered in the `/etc/sudoers` file:

```bash
# All adm1n68545 adm1n68545 all sudo privileges
adm1n68545 ALL=(ALL) ALL
```

**ATTENTION:** Before altering the ssh-server configs, you should open
up a second, stable shell to the server. Otherwise, you can lock yourself
out of the system.


### 3. Configure SSH server
Edit the file `/etc/ssh/sshd_config` to allow the ssh login for `adm1n68545`:

```bash
AllowUsers adm1n68545 adm1n68545
AllowUsers root root
```

**Note:** The user `root` is temporarily listed here, as root must be explicitly listed here when using AllowUsers. Otherwise a login with `root` will fail.

### 4. adjust access rights for `authorized_keys`
If no different user from `root` was created when the server was set up, the login of `adm1n68545` fails because the file `authorized_keys` still belongs to the user `root`.

Change the ownership rights with :

```bash
sudo chown adm1n68545:adm1n68545 /root/.ssh/authorized_keys
```

Now `adm1n68545` can log in via SSH.

### 5. Explicitly prohibit root login
Although the direct login via `root` should already fail because the `authorized_keys` file no longer belongs to it, it is safer to explicitly deactivate the root login. Change the file `/etc/ssh/sshd_config` as follows:

```bash
# Authentication:
PermitRootLogin no
```

The SSH server is then restarted to apply the changes:

```bash
sudo systemctl restart ssh
```

### 6. Verify changes

The following command should fail:

```bash
ssh root@[IP-adress server]
```
The follwing command should work:

```bash
ssh adm1n68545@[IP-adress server]
```

**Note:**Only now you should close the second shell.



