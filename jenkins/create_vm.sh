# Create Jenkins installation script into a file: cloud-init-jenkins.txt
printf "\n\n"
echo "########## Starting the job ##########"
echo "########## Version 1.0 ##########"
echo "########## Created by Raghavendra ##########"
printf "\n\n"

mkdir jenkins-server
cd jenkins-server
cat <<EOF > cloud-init-jenkins.txt
#cloud-config
package_upgrade: true
runcmd:
  - sudo apt install openjdk-21-jre -y
  - curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  - echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  - sudo apt-get update && sudo apt-get install jenkins -y
  - sudo service jenkins restart
EOF

printf "\n\n"

echo "########## Created Jenkins installation script ##########"
echo "########## Now creating SSH Keys ##########"

printf "\n\n"


# Create SSH key pair
ssh-keygen -t rsa -b 2048 -f ./jenkins-rg -N ""
chmod 600 jenkins-rg

printf "\n\n"

echo "########## Created SSH key pair ##########"
echo "########## Now creating Resource group ##########"

printf "\n\n"

# Create resource group
az group create --name jenkins-rg --location eastus

printf "\n\n"

echo "########## Created Resource group ##########"
echo "########## Now creating the VM ##########"

printf "\n\n"

# Create the VM
az vm create \
  --resource-group jenkins-rg \
  --name jenkins-vm \
  --image canonical:ubuntu-24_04-lts:server:24.04.202411030 \
  --admin-username "azureuser" \
  --ssh-key-value ./jenkins-rg.pub \
  --public-ip-sku Standard \
  --custom-data cloud-init-jenkins.txt \
  --size Standard_B2s \
  --storage-sku Standard_LRS

printf "\n\n"

echo "########## Created Jenkins vM ##########"
echo "########## Now opening jenkins Port 8080 ##########"

printf "\n\n"

# Open port 8080
az vm open-port \
--resource-group jenkins-rg \
--name jenkins-vm \
--port 8080 \
--priority 1010

printf "\n\n"

echo "########## Port 8080 opened ##########"
echo "########## Now obtaining the Public IP of the VM ##########"

printf "\n\n"

# Populate the VM Public IP to a variable $jenkinspip
jenkinspip=$(az vm show \
--resource-group jenkins-rg \
--name jenkins-vm -d \
--query [publicIps] --output tsv | tr -d '[:space:]')

printf "\n\n"

echo "########## Obtained the Public IP of the VM: $jenkinspip ##########"
echo "########## Populating SSH known_hosts file with the VM host key to ensure a non-interactive login ##########"

printf "\n\n"

# Add the host key in the ~/.ssh/known_hosts file 
ssh-keyscan -H $jenkinspip >> ~/.ssh/known_hosts

printf "\n\n"

echo "########## Added Host key ##########"

printf "\n\n"

echo "########## Waiting for 4 minutes to install the software defined in cloud-init ##########"

# Countdown timer
for ((i=240; i>0; i--)); do
    printf "\rTime remaining: %3d seconds" "$i"
    sleep 1
done
echo -e "\nTimer completed!"


printf "\n\n"

echo "########## Connecting to the Jenkins VM and installing AZ CLI and SSHPass ##########"

printf "\n\n"

# SSH into the Jenkins VM
# Install Azure CLI & SSH pass
ssh -i ./jenkins-rg azureuser@$jenkinspip <<EOF
sudo su -
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
apt install sshpass -y
EOF

printf "\n\n"

echo "########## The server is created successfully and you can access at http://$jenkinspip:8080 ##########"
echo "########## You are back to your Laptop ##########"
echo "########## This last step of SSH and installing  Azure CLI & SSH pass can be avoided, if you dd the insructions to cloud-init ##########'

printf "\n\n"

echo "########## CLEANING UP THE FILES AND FOLDERS THAT ARE CREATED FOR THIS OPERATION FROM YOUR LAPTOP##########"
rm -rf *
clear




