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

/*


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
 }*/