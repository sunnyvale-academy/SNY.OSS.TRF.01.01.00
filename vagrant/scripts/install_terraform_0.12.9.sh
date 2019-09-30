sudo apt-get install unzip
rm /usr/local/bin/terraform 2> /dev/null
if [ ! -f /usr/local/bin/terraform ]; then
    wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip
    unzip terraform_0.12.9_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm -f /home/vagrant/terraform_0.12.9_linux_amd64.zi*
fi
