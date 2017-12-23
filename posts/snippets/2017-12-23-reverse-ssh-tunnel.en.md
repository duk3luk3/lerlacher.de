---
title: SSH Reverse Tunnel
tags: ssh
---

This is a neat trick to keep a device sitting behind NAT reachable as long as it can make outbound SSH connections.

You need an endpoint for the tunnel to connect to, of course - this can be any host that has an SSH server and a stable connection to the internet.

Here is the script to establish the SSH connection with the reverse tunnel:

<script src="https://gist.github.com/duk3luk3/94aa449a7668cf549ecb79bdc8a52901.js?file=ssh_tunnel.sh"></script>

To test this, simply run the SSH command from your device:

`ssh -i $IF -o "ServerAliveInterval=60" -o "ExitOnForwardFailure=yes" -R 19999:localhost:22 $ADDR -N`

And on your endpoint, run:

`ssh -P 19999 user@localhost`

This also works as a SSH proxy connection that you can configure in your ssh config:

```
Host name.prox
Hostname localhost
User user
Port 19999
ProxyCommand ssh -W %h:%p user@endpoint
ServerAliveInterval 10
```

Once you've got it working, you can turn it into a systemd service (replace the path and the `USER`!):

<script src="https://gist.github.com/duk3luk3/94aa449a7668cf549ecb79bdc8a52901.js?file=ssh_tunnel.service"></script>

And on the endpoint, you can monitor the SSH connection, e.g. with monit:

<script src="https://gist.github.com/duk3luk3/94aa449a7668cf549ecb79bdc8a52901.js?file=ssh-tunnel.monit"></script>

This will send you an e-mail whenever the tunnel stops working.
