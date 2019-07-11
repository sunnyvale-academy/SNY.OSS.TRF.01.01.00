resource "google_compute_instance" "webserver" {
 name         = "${var.INSTANCE_NAME}"
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
    private_key = "${file("${var.SSH_PRIV_KEY_FILEPATH}")}"
  }
 }



 boot_disk {
   initialize_params {
    image = "${var.IMAGE}"
   }
 }

 network_interface {
   subnetwork = "${var.PUBLIC_SUBNET_REF}"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

  metadata = {
   ssh-keys = "${var.VM_USERNAME}:${file("${var.SSH_PUB_KEY_FILEPATH}")}"
 }

  
}

