#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

CONFIG_PATH=./crypto-config.yaml
TEMPLATE_PATH=./templates/cryptoConfigTemplate.yaml

ORG_SUFFIX=$1
: ${ORG_SUFFIX:="example"}

ORDERER_COUNT=$2
: ${ORDERER_COUNT:=3}

PEERORG_COUNT=$3
: ${PEERORG_COUNT:=2}

PEER_COUNT=$4
: ${PEER_COUNT:=3}

if [ -f $CONFIG_PATH ]; then
        rm $CONFIG_PATH
fi

cp $TEMPLATE_PATH $CONFIG_PATH

yq w -i $CONFIG_PATH OrdererOrgs.[0].Name $ORG_SUFFIX
yq w -i $CONFIG_PATH OrdererOrgs.[0].Domain $ORG_SUFFIX
yq w -i $CONFIG_PATH OrdererOrgs.[0].Template.Count $ORDERER_COUNT


counter=1
while [ $counter -le 100 ]; do

        if [ $counter -gt $PEERORG_COUNT ]; then
                break
        fi

        yq w -i $CONFIG_PATH PeerOrgs.[+].Name org$counter-$ORG_SUFFIX
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Domain org$counter-$ORG_SUFFIX
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].EnableNodeOUs true
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Template.Count $PEER_COUNT
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Users.Count 1

        ((counter++))

done

cat $CONFIG_PATH
