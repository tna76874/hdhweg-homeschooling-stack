# Jitsi

To set up jitsi run the playbook with the `jitsi` tag. If you want to customize your jitsi server (e.g. a logo), either place the watermark file in the folder `files` or link to a URL. Check the [variables](https://github.com/tna76874/hdhweg-homeschooling-stack/blob/master/roles/jitsi/defaults/main.yml) that you might add to `vars.yml`. 

```bash
sudo ansible-playbook /root/hdhweg-homeschooling-stack/main.yml -t jitsi
```

