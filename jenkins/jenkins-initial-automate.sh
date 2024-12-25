#!/bin/bash

# Start Jenkins service
sudo systemctl start jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Retrieve the initial admin password
ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Admin password retrieved: $ADMIN_PASSWORD"

# Download Jenkins CLI
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar

# Install recommended and additional plugins
cat <<EOL > plugins.txt
ant
apache-httpcomponents-client-4-api
asm-api
azure-cli
azure-credentials
azure-sdk
azure-vm-agents
bootstrap5-api
bouncycastle-api
branch-api
build-timeout
caffeine-api
checks-api
command-launcher
commons-lang3-api
commons-text-api
credentials-binding
credentials
dark-theme
display-url-api
durable-task
echarts-api
eddsa-api
email-ext
cloudbees-folder
docker-commons
docker-workflow
font-awesome-api
git-client
git
github-api
github-branch-source
github
gradle
instance-identity
ionicons-api
jackson2-api
jakarta-activation-api
jakarta-mail-api
jjwt-api
jaf-api
javax-mail-api
jaxb
joda-time
jquery3-api
json-api
json-path-api
junit
kubernetes
kubernetes-cli
kubernetes-credentials
kubernetes-cd
ldap
mailer
maven-plugin
matrix-auth
matrix-project
metrics
mina-sshd-api-common
mina-sshd-api-core
okhttp-api
jdk-tool
antisamy-markup-formatter
pam-auth
pipeline
pipeline-graph-analysis
pipeline-graph-view
pipeline-api
pipeline-build-step
pipeline-declarative
pipeline-declarative-extensions
pipeline-github-lib
workflow-cps
pipeline-groovy-lib
pipeline-input-step
workflow-job
pipeline-milestone-step
pipeline-model-api
powershell
workflow-multibranch
workflow-durable-task-step
workflow-scm-step
pipeline-stage-step
pipeline-stage-tags-metadata
workflow-step-api
workflow-support
plain-credentials
plugin-util-api
resource-disposer
scm-api
script-security
snakeyaml-api
ssh-slaves
ssh-credentials
sshd
structs
terraform
theme-manager
timestamper
token-macro
trilead-api
variant
ws-cleanup
EOL

echo "Installing plugins..."
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$ADMIN_PASSWORD install-plugin $(cat plugins.txt | tr '\n' ' ')

# Create the first admin user with email using Groovy script
cat <<EOL > create_admin_user.groovy
import jenkins.model.*
import hudson.security.*
import hudson.tasks.Mailer

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = hudsonRealm.createAccount('raghavendra', '123456789aA#')
user.addProperty(new Mailer.UserProperty("cloudops06@gmail.com"))
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOL

echo "Creating admin user..."
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$ADMIN_PASSWORD groovy = < create_admin_user.groovy

# Restart Jenkins
echo "Restarting Jenkins..."
sudo systemctl restart jenkins

echo "Jenkins setup completed. Admin user: raghavendra, Email: cloudops06@gmail.com"
