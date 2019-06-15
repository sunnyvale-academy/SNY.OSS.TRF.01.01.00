# Getting started

## Configure Google Cloud Platform

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.004.png) 


![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.005.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.006.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.007.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.008.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.009.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.010.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.011.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.012.png) 

![Vagrant](img/keynote-Cloud_infrastructure_automation_with_Terraform.013.png) 


## Lab VM setup

Please refer to [Vagrant](../../vagrant/README.md) instructions


## Configure Terraform (within the VM)

Connect to the VM using ssh

```
$ cd <GIT_REPO_NAME>/vagrant
$ vagrant ssh
```

Move to the right path and create your lab folder

```
vagrant@terraform-vm$ cd ~/$GIT_REPO_NAME/labs/01-Getting_started
```

Create a new directory for the project to live and create a main.tf file for the Terraform config. The contents of this file describe all of the GCP resources that will be used in the project.

```
vagrant@terraform-vm$ mkdir mylab
vagrant@terraform-vm$ cd mylab
vagrant@terraform-vm$ vi main.tf
```

Write the following code into main.tf file

```
// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("<CREDENTIALS_JSON_FILE>")}"
 project     = "<GCP_PROJECT_ID>"
 region      = "europe-west4"
}
```







