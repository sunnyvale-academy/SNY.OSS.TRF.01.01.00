// Google Cloud Engine instances


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
