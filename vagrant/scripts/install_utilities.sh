# Dependencies
sudo apt-get update
sudo apt-get -y install dos2unix
// to generate png from Terraform Graphs
sudo apt-get install -y graphviz python-pydot python-pydot-ng python-pyparsing libcdt5 libcgraph6 libgvc6 libgvpr2 libpathpla#n4 jq

# Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# GCP SDK
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get -y install google-cloud-sdk
