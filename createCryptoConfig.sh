#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

#Localisation of the different files
CONFIG_PATH=./crypto-config.yaml
TEMPLATE_PATH=./templates/cryptoConfigTemplate.yaml

#Default of Fabric network
ORG_SUFFIX=example
ORDERER_COUNT=3
PEERORG_COUNT=2
PEER_COUNT=3

function printHelp(){
        echo "  createClusterConfig.sh [-a <org suffix>] [-z <number of orderers>] [-e <number of organisation>] [-r <number of peer per org>]"
        echo "  byfn.sh -h (print this message)"
        echo
        echo "  This script will generate the cluster-config.yaml / crypto-config.yaml file"
        echo "  All the peer organisations will we name as following : org<number>-<org suffix>"
        echo
        echo "  You'll need to have yq in your path to execute this script"
}

command -v yq >/dev/null 2>&1 || { echo -e "${RED}[ERROR]${NC} In order to run this script, you must install yq : https://github.com/mikefarah/yq/" >&2; exit 1; }

while getopts ":h:a:z:e:r:" opt; do
        case "$opt" in
                h)
                        printHelp
                        exit
                ;;
                a) ORG_SUFFIX=$OPTARG;;
                z) ORDERER_COUNT=$OPTARG;;
                e) PEERORG_COUNT=$OPTARG;;
                r) PEER_COUNT=$OPTARG;;
        esac
done


if [ -f $CONFIG_PATH ]; then
        echo -e "${YELLOW}[INFO]${NC} The previous configuration file has been deleted"
        rm $CONFIG_PATH
fi

cp $TEMPLATE_PATH $CONFIG_PATH


echo -e "${YELLOW}[INFO]${NC} Configuration of the orderers"
yq w -i $CONFIG_PATH OrdererOrgs.[0].Name $ORG_SUFFIX
yq w -i $CONFIG_PATH OrdererOrgs.[0].Domain $ORG_SUFFIX
yq w -i $CONFIG_PATH OrdererOrgs.[0].Template.Count $ORDERER_COUNT


echo -e "${YELLOW}[INFO]${NC} Configuration of the peer organisations"
counter=1
while [ $counter -le 100 ]; do

        if [ $counter -gt $PEERORG_COUNT ]; then
                break
        fi

        echo -e "${YELLOW}[INFO]${NC} Configuration of org$counter-$ORG_SUFFIX"
        yq w -i $CONFIG_PATH PeerOrgs.[+].Name org$counter-$ORG_SUFFIX
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Domain org$counter-$ORG_SUFFIX
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].EnableNodeOUs true
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Template.Count $PEER_COUNT
        yq w -i $CONFIG_PATH PeerOrgs.[$(($counter-1))].Users.Count 1

        ((counter++))

done

echo -e "${GREEN}[OK]${NC} The file has been successfully generated"
cat $CONFIG_PATH
