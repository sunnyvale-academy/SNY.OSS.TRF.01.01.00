// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "my-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}"

 

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

resource "google_compute_attached_disk" "disk1_attachment" {
  disk = "${google_compute_disk.disk1.self_link}"
  instance = "${google_compute_instance.default.self_link}"

  provisioner "remote-exec" {
   inline = [
     "sudo parted /dev/sdb --script -- mklabel msdos",
     "sudo parted -a optimal /dev/sdb mkpart primary 0% 1024MB",
     "sudo mkfs.ext4 /dev/sdb1",
     "sudo mkdir dir /mnt/test-disk",
     "sudo mount -t ext4 /dev/sdb1 /mnt/test-disk"
   ]

   connection {
    type     = "ssh"
    host     = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
 }
}
