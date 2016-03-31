#!/bin/bash

# Configuration Parameters
DIR_root="/Users/teeerkunt/Documents/SVN_Repository/scripts/terrasible"
DIR_infra="${DIR_root}/infra"
DIR_cm="${DIR_root}/cm"

BIN_terraform="/usr/local/bin/terraform"
BIN_ansiblePlaybook='/usr/local/bin/ansible-playbook'

terraformStateFile="${DIR_infra}/terraform.tfstate"

ansiblePlaybook="${DIR_cm}/main.yml"
ansibleHosts="${DIR_cm}/hosts"
ansibleUser="ubuntu"

nginxConfTemplate="${DIR_cm}/files/nginx-template.conf"
nginxConfFinal="${DIR_cm}/files/nginx.conf"
sedPattern="__THISWILLBECHANGED__"

publicKey="~/.ssh/publicKeys/id_rsa.pub"

# First let's spin up the infrastructure
echo "---> Initiating the instances.."

cd ${DIR_infra}
${BIN_terraform} apply
if [ $? -ne 0 ]; then
    echo "FATAL ERROR: It seems there there is problem with creating the AWS Infrastructure."
    exit -1
fi
echo "<--- Finished spinning up the instances."

# Get the number of APP Servers
numberOfAppServers=`${BIN_terraform} output | grep app.ip | sort -nr | cut -d "." -f3 | head -n1`
echo "<--- Total number of $(expr $numberOfAppServers + 1) app servers initialized."

# Let's also create hosts file for Ansible
echo "[web]" > $ansibleHosts
${BIN_terraform} output web.ip.0.public >> $ansibleHosts
echo "" >> $ansibleHosts

# Fetch related IPs for nginx configuration
echo "---> Creating NGINX Configuration at ${nginxConfFinal}"

#
# We don't need an array here normally, but maybe be useful for the future.
webPublicIP="`${BIN_terraform} output web.ip.0.public`"
echo "[app]" >> $ansibleHosts
for i in `seq 0 ${numberofAppServer}`;
do
    echo `${BIN_terraform} output app.ip.${i}.public` >> $ansibleHosts
done

APPIPS=()
for i in `seq 0 ${numberofAppServers}`;
do
    IP=`${BIN_terraform} output app.ip.${i}.private`
    echo "---> Added App #${i} ( ${IP} )"
    APPIPS+=(${IP})
done

#
# We could just done this instead of pushing IPs into the array instead
STRING=""
for IP in ${APPIPS[@]};
do
    STRING+="server ${IP}:8484;"
done

sed "s/${sedPattern}/${STRING}/g" < $nginxConfTemplate > $nginxConfFinal

#
# Be sure that all hosts are up!
echo "---> Checking if hosts are up and available."
SERVERS=(`${BIN_terraform} output | grep public | cut -d "=" -f2 | tr -s "\n" " "`)
for i in ${SERVERS[@]};
do
    echo -ne "---> ${i}."
    while ! ping -c1 ${i} &>/dev/null;
    do
        echo -ne "."
        sleep 1
    done
    echo -ne "Alive!\n"
done

echo "---> Sleeping 30 more seconds to be sure that sshd is up!"
sleep 30

#
# Let the ansible handles the rest
cd ..
$BIN_ansiblePlaybook -v --inventory-file=$ansibleHosts --key-file=$publicKey -u $ansibleUser $ansiblePlaybook
if [ $? -ne 0 ]; then
    echo "FATAL ERROR: It seems there there is problem with provisioning."
    echo "             I would try to remove all infrastructure with 'terraform destroy' and try once again from scratch."
    exit -1
fi
echo "All done."

echo "Point your browser to http://${webPublicIP}:8484 to test if it's properly working."