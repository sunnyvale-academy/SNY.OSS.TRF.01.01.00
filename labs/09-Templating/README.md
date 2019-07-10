# Templating

We will create an infrastrucure like the one showed here after:

![Lab architecture](img/architecture.png)

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
vagrant@terraform-vm$ cd ~/$GIT_REPO_NAME/labs/09-Templating
```

Create a new directory for the project to live and create a main.tf file for the Terraform config. The contents of this file describe all of the GCP resources that will be used in the project.

```
vagrant@terraform-vm$ mkdir mylab
vagrant@terraform-vm$ cd mylab
```

We will create the few files in order to setup the cloud infrastrucure:

- vars.tf
- terraform.tfvars
- providers.tf
- vpc.tf
- subnets.tf
- routers.tf
- firewall_rules.tf
- instances.tf

First, we create the file **vars.tf** in order to declare the variables we are going to use (and their default value):

```
variable "CREDENTIAL_FILE" {}
variable "VM_USERNAME" {}
variable "PROJECT_ID" {}
variable "REGION" {
    default="us-west1"
}

variable "ZONE" {
    default="a"
}
variable "VPC_NAME" {
     default="test-vpc"
}
variable "PUBLIC_SUBNET_CDIR" {
    default="10.26.1.0/24"
}
variable "PRIVATE_SUBNET_CDIR" {
    default="10.26.2.0/24"
}
variable "APPSERVERS_COUNT" {
    default="3"
}

variable "IMAGE" {
    type="map"
    default={
        "us-west1-a"="debian-cloud/debian-9"
        "us-west2-a"="debian-cloud/debian-8"
    }
}
```

Differently from the previous lab **08-Cloud_network_modelling**, we removed every statically typed ip address, leaving only the subnet adresses.

Let's create the **terraform.tfvars** file with the actual variables value (chage the placeholders accordingly):

```
CREDENTIAL_FILE="/home/vagrant/<YOUR_FILE_NAME>.json"
PROJECT_ID="<YOUR_PROJECT>"
REGION="us-west1"
ZONE="a"
VM_USERNAME="<YOUR_USERNAME>"
APPSERVERS_COUNT="3"
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

Now that we configured the Terraform environment, we can proceed to declare the VPC, within the **vpc.tf** file insert:

```
resource "google_compute_network" "vpc" {
  name          =  "${var.VPC_NAME}-${random_id.random_id.hex}"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL" //REGIONAL or GLOBAL
}
```

...and the **subnets.tf** as well:

```
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet-${random_id.random_id.hex}"
  ip_cidr_range = "${var.PUBLIC_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-${random_id.random_id.hex}"
  ip_cidr_range = "${var.PRIVATE_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}
```

Public subnet is routed to the internet thanks to the default GCP router. To let the private subnet reach the internet (useful to provision with software the instance that will be created on it) we have to create a new router and the nat gateway.

Within the **routers.tf** file please insert:

```
resource "google_compute_router" "router" {
  name    = "router-${random_id.random_id.hex}"
  region  = "${var.REGION}"
  network = "${google_compute_network.vpc.self_link}"
}

resource "google_compute_router_nat" "nat-gw" {
  name                               = "nat-gw-${random_id.random_id.hex}"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.REGION}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = "${google_compute_subnetwork.private_subnet.self_link}"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
```

To govern what traffic can flow back and forth from subnets, the following firewall rules have to be inserted in **filrewall_rules.tf**  file.

```
resource "google_compute_firewall" "allow-internal" {
  name    = "fw-allow-internal-${random_id.random_id.hex}"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "${var.PUBLIC_SUBNET_CDIR}",
    "${var.PRIVATE_SUBNET_CDIR}"
  ]
}
resource "google_compute_firewall" "allow-http-ingress" {
  name    = "fw-http-ingress-${random_id.random_id.hex}"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}


resource "google_compute_firewall" "allow-ssh-ingress" {
  name    = "fw-ssh-ingress-${random_id.random_id.hex}"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"] 
}

```
Each rule will be targeted to the instance/s thanks to the *target_tags* value.

Finally we declare the instances within the file instances.tf:

```
// Two Google Cloud Engine instances


// Web server instance
resource "google_compute_instance" "webserver" {
 name         = "fe-${random_id.random_id.hex}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}-${var.ZONE}"
 tags         = ["ssh","http"]


 provisioner "remote-exec" {
   inline = [
     "sudo apt-get install -y nginx"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }



 boot_disk {
   initialize_params {
    image = "${lookup(var.IMAGE,"${var.REGION}-${var.ZONE}")}"
   }
 }

 network_interface {
   subnetwork = "${google_compute_subnetwork.public_subnet.self_link}"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

  metadata = {
   ssh-keys = "${var.VM_USERNAME}:${file("~/.ssh/id_rsa.pub")}"
 }

  
}

output "webserver-ip" {
    value = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
}





// App server instance/s
resource "google_compute_instance" "appserver" {
 name         = "be-${random_id.random_id.hex}-${count.index}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}-${var.ZONE}"
 count        = "${var.APPSERVERS_COUNT}"
 /*tags          = ["ssh","http"]*/
 
 boot_disk {
   initialize_params {
    image = "${lookup(var.IMAGE,"${var.REGION}-${var.ZONE}")}"
   }
 }

 network_interface {
   subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"
   
   /*access_config {
     // Include this section to give the VM an external ip address
   }*/
 }

  metadata = {
   ssh-keys = "${var.VM_USERNAME}:${file("~/.ssh/id_rsa.pub")}"
 }
  
}

resource "null_resource" "provision_be" {
  count = "${var.APPSERVERS_COUNT}"
  triggers = {
      cluster_instance_ips = "${join(",", google_compute_instance.appserver.*.network_interface.0.network_ip)}"
  }
  provisioner "remote-exec" {
   inline = [
      "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -",
      "sudo apt-get install -y build-essential nodejs",
      "mkdir ~/myapp",
      "npm install express --prefix ~/myapp --save",
      "npm install forever --prefix ~/myapp --save",
   ]

   connection {
    type     = "ssh"
    host     = "${element(google_compute_instance.appserver.*.network_interface.0.network_ip, count.index)}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"

    bastion_host = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
    bastion_port = "22"
    bastion_user = "${var.VM_USERNAME}"
  }
 }
 provisioner "file" {
    source      = "../app/"
    destination = "~/myapp/"

    connection {
      type     = "ssh"
      host     = "${element(google_compute_instance.appserver.*.network_interface.0.network_ip, count.index)}"
      user     = "${var.VM_USERNAME}"
      private_key = "${file("~/.ssh/id_rsa")}"

      bastion_host = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
      bastion_private_key = "${file("~/.ssh/id_rsa")}"
      bastion_port = "22"
      bastion_user = "${var.VM_USERNAME}"
   }
}

provisioner "remote-exec" {
   inline = [
      "sudo chmod a+x /home/${var.VM_USERNAME}/myapp/start_app.sh",
      "/home/${var.VM_USERNAME}/myapp/start_app.sh",
      "sleep 10"
   ]

   connection {
    type     = "ssh"
    host     = "${element(google_compute_instance.appserver.*.network_interface.0.network_ip, count.index)}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"

    bastion_host = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
    bastion_port = "22"
    bastion_user = "${var.VM_USERNAME}"
  }
 }
}


resource "null_resource" "be-cluster" {

    triggers = {
      cluster_instance_ips = "${join(",", google_compute_instance.appserver.*.network_interface.0.network_ip)}"
  }
   provisioner "file" {
       content      = "${templatefile("../templates/nginx.conf.tmpl",{port = 3000, ip_addrs = "${google_compute_instance.appserver.*.network_interface.0.network_ip}"})}"
       destination = "/tmp/demo"

    connection {
      type     = "ssh"
      host     = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
      user     = "${var.VM_USERNAME}"
      private_key = "${file("~/.ssh/id_rsa")}"
   }
}

provisioner "remote-exec" {
   inline = [
     "sudo cp /tmp/demo /etc/nginx/sites-available/demo",
     "sudo chmod 644 /etc/nginx/sites-available/demo",
     "sudo rm -f /etc/nginx/sites-enabled/default",
     "sudo rm -f /etc/nginx/sites-enabled/demo",
     "sudo ln -s /etc/nginx/sites-available/demo /etc/nginx/sites-enabled/demo",
     "sudo /etc/init.d/nginx restart"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.webserver.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }
 }

```

Every instance contains provisioners, in order to be configured right after being created.

```
vagrant@terraform-vm$ terraform init
...
vagrant@terraform-vm$ terraform plan
...
vagrant@terraform-vm$ terraform apply
...

```

The infrastructure will be created. In order to test the application point your browser to the public IP showed by the ip output variable.


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



