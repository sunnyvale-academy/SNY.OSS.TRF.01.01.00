# Output variables

## Prerequisites

Having completed labs 00, 01, 02, and 04. 

If you did not finish lab 04, you can take *.tf files in the solution folder.

## Connect to the Vagrant VM

Connect to the VM using ssh

```
$ cd <GIT_REPO_NAME>/vagrant
$ vagrant ssh
```

Move to the right path and create your lab folder

```
vagrant@terraform-vm$ cd ~/$GIT_REPO_NAME/labs/05-Output_variables
```

Create a new directory for the project to live and create a main.tf file for the Terraform config. The contents of this file describe all of the GCP resources that will be used in the project.

```
vagrant@terraform-vm$ mkdir mylab
vagrant@terraform-vm$ cd mylab
vagrant@terraform-vm$ cp ../04-Variables/mylab/* ./
```

If you haven't complete the 04-Variables lab, you can take *.tf files from the solution folder.


Add the following snippet in instance.tf at the end of the file, outside any other declaration

```
output "ip" {
    value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
```

Type the following commands (type yes when prompted for the final confirmation)

```
vagrant@terraform-vm$ terraform init
vagrant@terraform-vm$ terraform plan
vagrant@terraform-vm$ terraform apply
```

you should see an output like this, with the ip value under *Outputs:* section

```
random_id.instance_id: Creating...
random_id.instance_id: Creation complete after 0s [id=H0Q0U81lNZ8]
google_compute_instance.default: Creating...
google_compute_instance.default: Still creating... [10s elapsed]
google_compute_instance.default: Creation complete after 12s [id=my-vm-1f443453cd65359f]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

ip = 34.83.56.48
```

If you query for the ip output variable, you should get its value

```
vagrant@terraform-vm$ terraform output ip
34.83.56.48
```


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



