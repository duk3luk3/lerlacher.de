---
title: Emergency private key tutorial
tags: digitalocean, ssh
---

It appears that DigitalOcean is currently experiencing some issues getting the password emails for new droplets out, as well as password reset e-mails, so quite a few users are having problems getting into new droplets.

While I hope DO gets that fixed quickly, here's an emergency walkthrough to use ssh keys instead of passwords to side-step the problem.  
Note that it only works for new droplets, not existing ones!

# Windows

1. Download PuTTy and PuttyGen from the [PuTTy website](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
2. Follow the steps in the "Generating OpenSSH-compatible Keys for Use with PuTTY" section of the [DigitalOcean PuttyGen tutorial](https://www.digitalocean.com/community/articles/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps#GeneratingOpenSSH-compatibleKeysforUsewithPuTTY)
3. Instead of copying the public key directly into a droplet, you have to copy it into the [DigitalOcean Control Panel](https://cloud.digitalocean.com/login). Log in, and go to the "SSH Keys" section (left sidebar menu). There, click "Add SSH Key", enter a name, and paste the key. Click "Create SSH Key".

Now when you create a new droplet, there is an "Add optional SSH Keys" section. Select the key there, and it will be loaded into the droplet when it is created.

Then follow the steps in the "Create a PuTTY Profile to Save Your Server's Settings" section of the [PuttyGen tutorial](https://www.digitalocean.com/community/articles/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps#CreateaPuTTYProfiletoSaveYourServer%27sSettings) and you should be able to log in!

# Mac OS X and Linux

1. Open a terminal
2. Run `ls ~/.ssh/`. If it returns an error that the directory doesn't exist, or shows a directory listing that does *not* show a file called id_rsa, run the command `ssh-keygen`. You can just hit enter on all prompts.
3. Run `cat ~/.ssh/id_rsa.pub` and copy the output
4. Log into your [DigitalOcean Control Panel](https://cloud.digitalocean.com/login), and go to the "SSH Keys" section (left sidebar menu). There, click "Add SSH Key", enter a name, and paste the key. Click "Create SSH Key".

Now when you create a new droplet, there is an "Add optional SSH Keys" section. Select the key there, and it will be loaded into the droplet when it is created.

To log into the new droplet, run `ssh root@your.droplet.ip`. You should be in!
