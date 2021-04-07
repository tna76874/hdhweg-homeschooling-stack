# Mailserver

A [mailserver](https://github.com/docker-mailserver/docker-mailserver) is very handy if it comes to sending out notifications to users, e.g. with the Rocket.Chat server. Ensure, that the subdomain `mail` points to your VM. Set up the mailserver with:

```bash
sudo ansible-playbook /root/hdhweg-homeschooling-stack/main.yml -t mail
```

With this command, first a restic backup of the mailserver directory will be perfomed, the setup and the env files are updated and the latest docker image gets pulled. Initially a user `postmaster` gets created with the script `setup.sh` and a randomly generated password. Update the user with a password of your choice - therefore study the [wiki](https://github.com/docker-mailserver/docker-mailserver/wiki/setup.sh).

##### DKIM, SPF and DMARC

To prevent that the emails send from your mailserver gets identified by spam, set the DKIM, SPF and DMARC DNS entrys in the config page of your dns provider. These configs are stored in `/srv/mailserver/dnsconfig.log`. It is also advised to set a reverse DNS in the config page of your VPS provider to point from your IP-adress to the `mail.` subdomain.