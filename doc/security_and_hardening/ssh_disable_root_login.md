
## Introduction
The direct root login via SSH represents a significant security risk. If this is activated, a potential attacker can directly attempt to log in as root. Deactivating the root login increases security, as an attacker must also guess the user name to gain access.

## Instructions for deactivating
### 1. create a new user

### ATTENTION: creating a username that is easy to guess is not recommended. If an SSH key falls into the wrong hands and the root login does not work, the user name must be guessed. A simple name such as user1, admin1 etc. is therefore a security risk

Creating a new user, e.g.  `admin68545`.

```bash
sudo adduser admin68545
```

### 2. Set authorizations for `admin68545`
Allow `admin68545` to execute root commands with `sudo`. To do this, `admin68545` can be added to the `sudo` group or entered in the `/etc/sudoers` file:

```bash
# All admin68545 admin68545 all sudo privileges
admin68545 ALL=(ALL) ALL
```

### 3. Configure SSH server
Edit the file `/etc/ssh/sshd_config` to allow the ssh login for `admin68545`:

```bash
AllowUsers admin68545 admin68545
AllowUsers root root
```

**Note:** The user `root` is temporarily listed here, as root must be explicitly listed here when using AllowUsers. Otherwise a login with `root` will fail.

### 4. adjust access rights for `authorized_keys`
If no different user from `root` was created when the server was set up, the login of `admin68545` fails because the file `authorized_keys` still belongs to the user `root`.

Change the ownership rights with :

```bash
sudo chown admin68545:admin68545 /root/.ssh/authorized_keys
```

Now `admin68545` can log in via SSH.

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


