resource "null_resource" "be-cluster" {
  /*  triggers = {
      cluster_instance_ips = "${join(",", google_compute_instance.appserver.*.network_interface.0.network_ip)}"
  }*/
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