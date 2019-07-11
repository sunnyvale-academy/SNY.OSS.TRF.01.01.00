// App server instance/s
resource "google_compute_instance" "appserver" {
 name         = "${var.INSTANCE_NAME}-${count.index}"
 machine_type = "f1-micro"
 zone         = "${var.REGION}-${var.ZONE}"
 count        = "${var.APPSERVERS_COUNT}"
 /*tags          = ["ssh","http"]*/
 
 boot_disk {
   initialize_params {
    image = "${var.IMAGE}"
   }
 }

 network_interface {
   subnetwork = "${var.PRIVATE_SUBNET_REF}"
   
   /*access_config {
     // Include this section to give the VM an external ip address
   }*/
 }

  metadata = {
    ssh-keys = "${var.VM_USERNAME}:${file("${var.SSH_PUB_KEY_FILEPATH}")}"
 }
  
}
