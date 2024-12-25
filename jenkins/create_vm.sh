# Create Jenkins installation script into a file: cloud-init-jenkins.txt
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
echo "Jenkins installation script"

# Create SSH key pair
ssh-keygen -t rsa -b 2048 -f ./jenkins-rg -N ""
chmod 600 jenkins-rg
echo "Created SSH key pair"

# Create resource group
az group create --name jenkins-rg --location eastus
echo "Resource group created"

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
echo "Jenkins vM created"

# Open port 8080
az vm open-port \
--resource-group jenkins-rg \
--name jenkins-vm \
--port 8080 \
--priority 1010
echo "Port 8080 opened"

# Populate the VM Public IP to a variable $jenkinspip
jenkinspip=$(az vm show \
--resource-group jenkins-rg \
--name jenkins-vm -d \
--query [publicIps] --output tsv | tr -d '[:space:]')
echo "jeninspip populated"

# Add the host key in the ~/.ssh/known_hosts file 
ssh-keyscan -H $jenkinspip >> ~/.ssh/known_hosts
echo "Host key added"

# SSH into the Jenkins VM
# Install Azure CLI & SSH pass
ssh -i ./jenkins-rg azureuser@$jenkinspip <<EOF
sudo su -
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
apt install sshpass -y
echo "AZ CLI & SSHPass installed"
EOF



