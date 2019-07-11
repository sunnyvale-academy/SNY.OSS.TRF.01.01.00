resource "google_compute_instance" "default" {
 name         = "myvm-${random_id.random_id.hex}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}-${var.ZONE}"
 tags         = ["ssh","http"]


 boot_disk {
   initialize_params {
    image = "${var.IMAGE}"
   }
 }

 network_interface {
   network = "default"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

  metadata = {
    ssh-keys = "${var.VM_USERNAME}:${file("${var.SSH_PUB_KEY_FILEPATH}")}"
 }

  
}