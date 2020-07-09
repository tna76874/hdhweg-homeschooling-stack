# hdhweg-homeschooling-stack

### Aim

These ansible playbook aims to setup a stack of homeschooling (Fernunterricht) tools on a single (virtual) server. The installation process, and much more important, the update process should be as less work as possible. All the tools of these playbook are deployed as self-updating docker-compose configurations. This will help you to set up a DSGVO compliant infrastructure for your school with **minimal efforts**. With your [Jitsi Meet](https://github.com/jitsi/jitsi-meet)  installation you can perform video-conferences including screen-mirroring - the configurations for the best performance are automatically included by this playbook. [Rocket.Chat](https://github.com/RocketChat/Rocket.Chat) is somehow a mix-up between Whatsapp and Discord and and nice way to communicate in chats with colleagues and students. When it comes to exchange files and collaboratively working on "excel" tables and text documents, [cryptpad](https://github.com/xwiki-labs/cryptpad) is the suitable tool. With a very simple structured [whiteboard](https://github.com/cracker0dks/whiteboard) you can collaborative work on a common blackboard together with students. Having a common platform to talk to each other is quite important right now. To keep up your lessons and the social structure of your school, you can use [Mumble](https://www.mumble.info/) as a voice-chat server. To work together on documents a [collabora](https://www.collaboraoffice.com/code/docker/) server gets deployed. You can use this server by suitable plugins of e.g. moodle or nextcloud installations (not included in this playbook).

While this repository sets up an server with collaborative tools, it might be not possible for some people to use the tools due to the lack of devices at home. Therefor a possible solution is a [ubuntu configuration playbook](https://github.com/tna76874/hdhweg-ubuntu) to set up a custom ubuntu installation image or configure an existing ubuntu installation.

> **Contributions are always welcome -- feel free to join this project.**

### Data privacy

It is mandatory to collect as less data as possbile - preferably none. A big advantage of the containerized applications of these stack is the dedicated selection of files that are kept and are necessary to run the applications. All other files are stored within the container-instance and get recreated every day. The configurations of these repository are optimized for as less data collection as possible - for the best of our knowledge.

* [Jitsi configurations](roles/jitsi) 


### Acknowledgement

Thanks to the ZSL/LFB and Ulm for their great ansible playbooks. The playbook of this repo is basing on these repos.

Check out these repos as well:

| Repo 	| Description 	|
|---	|-----------------------------------------------------------------------------	|
| [Ulm](https://github.com/stadtulm/a13-ansible)  	| A BigBlueButton-cluster with Prometheus monitoring and Greenlight frontend. 	|
| [Ulm](https://github.com/verschwoerhaus/ansible-bbb-cluster)  	| A *small scale* BigBlueButton-cluster with Prometheus monitoring.           	|
| [ZSL/LFB](https://codeberg.org/DigitalSouveraeneSchule/bbb.git) 	| The BigBlueButton-cluster of the ZSL/LFB accessed by a moodle-frontend.     	|

### Requirements

* A (virtual) server hosted by the company of your choice.
* A domain with an A-record pointing to the static IP-adress of your server.

### Prepare

Install all prerequisites:

```
wget -qO setup.sh https://raw.githubusercontent.com/tna76874/hdhweg-homeschooling-stack/master/setup.sh && chmod +x setup.sh && sudo bash setup.sh && rm setup.sh
```

**Remove the ssh-keys inside the file `vars.yml` to prevent ssh access of the listed users.** 

Set the variable `letsencrypt_email` to your mailadress. You don't want your students to have bad warning messages on your nice websites once your letsencrypt certificates expired.

Set `main_domain` to the domain that points at your VM. Be sure, that the subdomains `chat`, `tafel`, `jitsi`, `cryptpad`, `collabora`, and `mumble` also points to your VM.

Set `collabora_domain` to the domain your collabora server should serve its content to, e.g. `moodle.myschool.xyz`.

### Run

Run the playbook to fully set up your server.

```
$ sudo ansible-playbook main.yml
```

Initial start cryptpad, jitsi and the whiteboard. A watchtower instance keeps these docker-images up-to-date. Every night the whiteboard-docker gets restarted via cron.

```bash
sudo ansible-playbook /root/hdhweg-homeschooling-stack/main.yml --tags startdockers
```

If you want, you can start rocketchat, and mumble by entering the directorys in  `/srv/`.

### To-Do

- [ ] adding a simple mailserver to the stack
- [ ] restructure the mumble setup
- [ ] set up an interactive configuration script for the environment
- [ ] ...