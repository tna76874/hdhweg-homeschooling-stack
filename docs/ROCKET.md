# Rocket.Chat

If you already have a Rocket.Chat instance running, you might have set manually to the deprecated storage engine `mmapv1`. Add this block to your `vars.yml` .  

```yaml
config_env_mongo:
cmd_mongo: mongod --smallfiles --oplogSize 128 --replSet rs0 --storageEngine=mmapv1
cmd_mongo_init: '''bash -c "for i in `seq 1 30`; do mongo mongo/rocketchat --eval \"rs.initiate({ _id: ''''rs0'''', members: [ { _id: 0, host: ''''mongo:27017'''' } ]}$
```

