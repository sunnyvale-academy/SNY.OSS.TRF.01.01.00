// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "my-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}"


// Install software using remote-exec provisioner
 provisioner "remote-exec" {
   inline = [
      "sudo apt-get -y install tcpdump",
      "sudo apt-get -y install python"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }

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

 // Create the Ansible inventory locally using the local-exec provisioner 
 provisioner "local-exec" {
    command = "echo '[all]' > inventory.txt && echo ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip} >> inventory.txt"
 }

 // Provision using Ansible with local-exec provisioner
 provisioner "local-exec" {
    command = "sleep 40; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.VM_USERNAME} --private-key ~/.ssh/id_rsa -i inventory.txt ../playbooks/ansible-playbook.yml" 
 }

 boot_disk {
   initialize_params {
    image = "${lookup(var.IMAGE,var.REGION)}"
   }
 }

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
  }

  metadata = {
   ssh-keys = "${var.VM_USERNAME}:${file("~/.ssh/id_rsa.pub")}"
  }

 }


output "ip" {
    value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
