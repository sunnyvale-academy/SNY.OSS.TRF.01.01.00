resource "null_resource" "be-cluster" {
  triggers = {
      cluster_instance_ips = "${join(",", "${var.APPSERVERS_PRIV_IP_LIST}")}"
  }
   provisioner "file" {
       content      = "${templatefile("${var.NGINX_TEMPLATE_FILEPATH}",{port = 3000, ip_addrs = "${var.APPSERVERS_PRIV_IP_LIST}"})}"
       destination = "/tmp/demo"

    connection {
      type     = "ssh"
      host     = "${var.WEBSERVER_IP}"
      user     = "${var.VM_USERNAME}"
      private_key = "${file("${var.SSH_PRIV_KEY_FILEPATH}")}"
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
    host     = "${var.WEBSERVER_IP}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("${var.SSH_PRIV_KEY_FILEPATH}")}"
  }
 }
 }