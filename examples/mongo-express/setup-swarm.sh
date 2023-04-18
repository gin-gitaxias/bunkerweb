#!/bin/bash

# docker-compose doesn't support assigning labels to configs
# so we need to create the configs with the CLI
# bunkerweb.CONFIG_TYPE accepted values are http, stream, server-http, server-stream, default-server-http, modsec and modsec-crs
# bunkerweb.CONFIG_SITE lets you choose on which web service the config should be applied (MULTISITE mode) and if it's not set, the config will be applied for all services
# more info at https://docs.bunkerweb.io

# remove configs if existing
docker config rm cfg_me_modsec

# create configs
docker config create -l bunkerweb.CONFIG_TYPE=modsec -l bunkerweb.CONFIG_SITE=www.example.com cfg_me_modsec ./bw-data/configs/modsec/mongo-express.conf