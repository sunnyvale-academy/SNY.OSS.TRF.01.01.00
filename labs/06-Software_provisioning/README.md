# Software provisioning

## Prerequisites

Having completed labs 00, 01, 02, and 05. 

If you did not finish lab 05, you can take *.tf files in the solution folder.

## Connect to the Vagrant VM

Connect to the VM using ssh

```
$ cd <GIT_REPO_NAME>/vagrant
$ vagrant ssh
```

Move to the right path and create your lab folder

```
vagrant@terraform-vm$ cd ~/$GIT_REPO_NAME/labs/06-Software_provisioning
```

Create a new directory for the project to live and create a main.tf file for the Terraform config. The contents of this file describe all of the GCP resources that will be used in the project.

```
vagrant@terraform-vm$ mkdir mylab
vagrant@terraform-vm$ cd mylab
vagrant@terraform-vm$ cp ../../05-Output_variables/mylab/* ./
```

If you haven't complete the 05-Output_variables lab, you can take *.tf files from the solution folder.

We will modify the resourse google_compute_instance inside the instance.tf file by adding provisioners in order to perform the following tasks:

- Install tcpdump (using the **remote-exec** provisioner)
- Copy the file 'scripts/my_script.sh' (using the **file** provisioner)
- Executing the script my_script.sh on the target VM (using the **remote-exec** provisioner)
- Create a local Ansible inventory file containing the ip address of the target machine (using the **local-exec** provisioner)
- Install nginx using Ansible and the previously created inventory file (using the **local-exec** provisioner)

Open the instance.tf and locate the resourse google_compute_instance, you will place code snippets witin, i.e.:

```
...
resource "google_compute_instance" "default" {
  // You will place code snippets here
...
```

Add this snippet, it is used to install tcpdump on the target machine:

```
 // Install software using remote-exec provisioner
 provisioner "remote-exec" {
   inline = [
      "sudo apt-get -y install tcpdump"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }
```

Now add the following snippet, it is used to upload the provided my_script.sh into the target VM

```
 // Upload a file using file provisioner
 provisioner "file" {
       source      = "../scripts/my_script.sh"
       destination = "/tmp/my_script.sh"

    connection {
      type     = "ssh"
      host     = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
      user     = "${var.VM_USERNAME}"
      private_key = "${file("~/.ssh/id_rsa")}"
   }
 }
```
Now add the following snippet, it is used to change the permissions and execute the script on the target VM

```
 // Execute a script remotely using remote-exec provisioner
 provisioner "remote-exec" {
   inline = [
     "chmod a+x /tmp/my_script.sh",
      "/tmp/my_script.sh"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }
```

Now add the following snippet, it is used to create a file locally named inventory.txt, containing the VMs ip address in a format required by Ansible 

```
 // Create the Ansible inventory locally using the local-exec provisioner 
 provisioner "local-exec" {
    command = "echo '[all]' > inventory.txt && echo ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip} >> inventory.txt"
 }
```

Finally add the following snippet, it is used to execute the provided Ansible playbook toward the remote VM using the previously created inventory file

```
 // Provision using Ansible with local-exec provisioner
 provisioner "local-exec" {
    command = "sleep 40; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.VM_USERNAME} --private-key ~/.ssh/id_rsa -i inventory.txt ../playbooks/ansible-playbook.yml" 
 }
```

Now if you save the instance.tf file and execute the terraform commands, the provisioning starts and you should see an output like the one showed here below.

```

vagrant@terraform-vm$ terraform init
...
vagrant@terraform-vm$ terraform plan
... 
vagrant@terraform-vm$ terraform apply
...
google_compute_instance.default: Provisioning with 'local-exec'...
google_compute_instance.default (local-exec): Executing: ["/bin/sh" "-c" "echo '[all]' > inventory.txt && echo 34.83.56.48 >> inventory.txt"]
google_compute_instance.default: Provisioning with 'local-exec'...
google_compute_instance.default (local-exec): Executing: ["/bin/sh" "-c" "sleep 40; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u denis_maggiorotto --private-key ~/.ssh/id_rsa -i inventory.txt ../playbooks/ansible-playbook.yml"]
google_compute_instance.default: Still creating... [50s elapsed]
google_compute_instance.default: Still creating... [1m0s elapsed]
google_compute_instance.default: Still creating... [1m10s elapsed]
google_compute_instance.default: Still creating... [1m20s elapsed]

google_compute_instance.default (local-exec): PLAY [Install nginx] ***********************************************************

google_compute_instance.default (local-exec): TASK [setup] *******************************************************************
google_compute_instance.default: Still creating... [1m30s elapsed]
google_compute_instance.default (local-exec): ok: [34.83.56.48]

google_compute_instance.default (local-exec): TASK [Install base packages] ***************************************************
google_compute_instance.default: Still creating... [1m40s elapsed]
google_compute_instance.default (local-exec): changed: [34.83.56.48]

google_compute_instance.default (local-exec): PLAY RECAP *********************************************************************
google_compute_instance.default (local-exec): 34.83.56.48                : ok=2    changed=1    unreachable=0    failed=0

google_compute_instance.default: Creation complete after 1m48s [id=my-vm-0ee9ede014833adc]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

ip = 34.83.56.48
```

Let's check if everything went fine on the target VM:

```
vagrant@terraform-vm$ ssh -l denis_maggiorotto 34.83.56.48
denis_maggiorotto@my-vm-0ee9ede014833adc:~$ cat README.md 
I've been here
denis_maggiorotto@my-vm-0ee9ede014833adc:~$ apt list --installed | grep tcpdump
tcpdump/stable,stable,now 4.9.2-1~deb9u1 amd64 [installed]
denis_maggiorotto@my-vm-0ee9ede014833adc:~$ apt list --installed | grep nginx
libnginx-mod-http-auth-pam/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-dav-ext/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-echo/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-geoip/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-image-filter/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-subs-filter/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-upstream-fair/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-http-xslt-filter/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-mail/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
libnginx-mod-stream/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
nginx/stable,stable,now 1.10.3-1+deb9u2 all [installed]
nginx-common/stable,stable,now 1.10.3-1+deb9u2 all [installed,automatic]
nginx-full/stable,stable,now 1.10.3-1+deb9u2 amd64 [installed,automatic]
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



