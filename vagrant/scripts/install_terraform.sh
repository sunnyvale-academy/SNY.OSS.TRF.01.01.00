sudo apt-get install unzip
if [ ! -f /usr/local/bin/terraform ]; then
    wget https://releases.hashicorp.com/terraform/0.12.4/terraform_0.12.4_linux_amd64.zip
    unzip terraform_0.12.4_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm -f /home/vagrant/terraform_0.12.4_linux_amd64.zi*
fi
