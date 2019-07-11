# Terraform modules

We will create an infrastrucure like the one showed here after:

![Lab architecture](img/architecture.png)

In this lab, the files taken from the solution of **09-Templating** have been transformed to modules for you.

## Prerequisites

Having completed labs 00, 01, 02.

## Connect to the Vagrant VM

Connect to the VM using ssh

```
$ cd <GIT_REPO_NAME>/vagrant
$ vagrant ssh
```

Move to the right path and create your lab folder

```
vagrant@terraform-vm$ cd ~/$GIT_REPO_NAME/labs/10-Terraform_modules
```

In this directory, under the modules subfolder, you can find four Terraform modules:

- 2-tier_network
- frontend
- backend
- application
- cluster

Create a new directory for the project:

```
vagrant@terraform-vm$ mkdir mylab
vagrant@terraform-vm$ cd mylab
```

Here you will create the following terraform files

- variables.tf
- terraform.tfvars
- providers.tf
- main.tf
- outputs.tf

First, we create the file **variables.tf** in order to declare the variables we are going to use (and their default value):

```
variable "REGION" {
    default="us-west1"
}
variable "ZONE" {
    default="a"
}
variable "CREDENTIAL_FILE" {}
variable "VM_USERNAME" {}
variable "PROJECT_ID" {}


variable "IMAGE" {
    default="debian-cloud/debian-9"
}

variable "SSH_PUB_KEY_FILEPATH" {
    default="~/.ssh/id_rsa.pub"
}

variable "SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}

```

Let's create the **terraform.tfvars** file with the actual variables value (chage the placeholders accordingly):

```
CREDENTIAL_FILE="/home/vagrant/<YOUR_FILE_NAME>.json"
PROJECT_ID="<YOUR_PROJECT>"
REGION="us-west1"
ZONE="a"
VM_USERNAME="<YOUR_USERNAME>"
```

Now,  we create the file **providers.tf**, used to configure the GCP provider and the random_id plugin.

```
// Terraform plugin for creating random ids
resource "random_id" "random_id" {
 byte_length = 8
}

// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.CREDENTIAL_FILE}")}"
 project     = "${var.PROJECT_ID}"
 region      = "${var.REGION}"
}
```

...and, in the **outputs.tf** file, we instruct Terraform to print out the webserver IP address we will use to access our application


```
output "webserver-ip" {
    value = "${module.frontend.webserver-ip}"
}
```

In order to benefit from Terraform modules that have been developed, we will create a **main.tf** file that recalls them.

You are in charge to provide a value for each input variable where it's missing.

```
module "vpc" {
  source = "../modules/2-tier_network"
  VPC_NAME = 
  PUBLIC_SUBNET_CDIR = 
  PRIVATE_SUBNET_CDIR = 
}

module "frontend" {
  source = "../modules/frontend"
  INSTANCE_NAME = 
  SSH_PUB_KEY_FILEPATH = 
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from vpc module output
  PUBLIC_SUBNET_REF = 
  VM_USERNAME = "${var.VM_USERNAME}"
  IMAGE = "${var.IMAGE}"
}


module "backend" {
  source = "../modules/backend"
  INSTANCE_NAME = 
  SSH_PUB_KEY_FILEPATH = "~/.ssh/id_rsa.pub"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from vpc module output
  PRIVATE_SUBNET_REF =
  VM_USERNAME = "${var.VM_USERNAME}"
  IMAGE = "${var.IMAGE}"
  APPSERVERS_COUNT = "3"
}

module "application" {
  source = "../modules/application"
  // taken from backend module output 
  APPSERVERS_PRIV_IP_LIST = 
  VM_USERNAME = "${var.VM_USERNAME}"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  BASTION_VM_USERNAME = "${var.VM_USERNAME}"
  BASTION_SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from frontend module output
  BASTION_HOST_IP = 
  APP_DIRPATH = "../app/"
  // taken from backend module output 
  APPSERVERS_COUNT =
}


module "cluster" {
  source = "../modules/cluster"
  // taken from backend module output 
  APPSERVERS_PRIV_IP_LIST = 
  VM_USERNAME = "${var.VM_USERNAME}"
  // taken from frontend module output 
  WEBSERVER_IP = 
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  NGINX_TEMPLATE_FILEPATH = "../templates/nginx.conf.tmpl"
  // taken from backend module output 
  APPSERVERS_COUNT = 
}

```
Then try the plan

```
vagrant@terraform-vm$ terraform init
...
vagrant@terraform-vm$ terraform plan
...
vagrant@terraform-vm$ terraform apply
...

```

The infrastructure will be created. In order to test the application point your browser to the public IP showed by the webserver-ip output variable.


Remember to destroy resources (active VM cost)

```
vagrant@terraform-vm$ terraform destroy
random_id.instance_id: Refreshing state... [id=VPapVgriyvw]
google_compute_instance.default: Refreshing state... [id=my-vm-54f6a9560ae2cafc]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_instance.default will be destroyed
  - resource "google_compute_instance" "default" {
      - can_ip_forward       = false -> null
      - cpu_platform         = "Intel Broadwell" -> null
      - deletion_protection  = false -> null
      - guest_accelerator    = [] -> null
      - id                   = "my-vm-54f6a9560ae2cafc" -> null
      - instance_id          = "942803623566960790" -> null
      - label_fingerprint    = "42WmSpB8rSM=" -> null
      - labels               = {} -> null
      - machine_type         = "f1-micro" -> null
...
```
Type yes when prompted



