# hdhweg-homeschooling-stack

### Acknowledgement

Thanks to [Ulm](https://github.com/stadtulm/a13-ansible)  and the [ZSL](https://codeberg.org/DigitalSouveraeneSchule/bbb.git) for their great ansible playbooks, the plabook of this repo is based on.

### Prepare

Update your fresh VM and install git and ansible.

```
$ sudo apt update && sudo apt upgrade -y && sudo install git ansible -y
```

Clone this repo:
```
$ git clone XYZ
```

Create the playbook-variable-file.
```
$ cp vars.yml.example vars.yml
```

**Remove the ssh-keys inside the file `vars.yml` to prevent ssh access of the listed users.**

Set the variable `letsencrypt_email` to your mailadress. You don't want your students to have bad warning messages on your nice websites onve your letsencrypt certificates expired.

Set `main_domain` to the domain that points at your VM. Be sure, that the subdomains `chat`, `tafel`, `jitsi`, `cryptpad` and `mumble` also points to your VM.

### Run

Run the playbook to fully set up your server.

```
ansible-playbook main.yml
```

As default, cryptpad, jitsi and the whiteboard gets started by the playbook. Also a watchtower instance keeps these docker-images up-to-date.

If you want, you can start rocketchat, and mumble by entering the directorys in  `/srv/`.

### Questions

If you have some question regarding this script, you can write to [Mh@werkgymnasium.de](mailto:Mh@werkgymnasium.de) 