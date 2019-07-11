resource "null_resource" "provision_be" {
  count = "${var.APPSERVERS_COUNT}"
  
  triggers = {
      cluster_instance_ips = "${join(",", "${var.APPSERVERS_PRIV_IP_LIST}")}"
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
    host     = "${element("${var.APPSERVERS_PRIV_IP_LIST}", count.index)}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"

    bastion_host = "${var.BASTION_HOST_IP}"
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
    bastion_port = "22"
    bastion_user = "${var.VM_USERNAME}"
  }
 }
 provisioner "file" {
    source      = "${var.APP_DIRPATH}"
    destination = "~/myapp/"

    connection {
      type     = "ssh"
      host     = "${element("${var.APPSERVERS_PRIV_IP_LIST}", count.index)}"
      user     = "${var.VM_USERNAME}"
      private_key = "${file("~/.ssh/id_rsa")}"

      bastion_host = "${var.BASTION_HOST_IP}"
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
    host     = "${element("${var.APPSERVERS_PRIV_IP_LIST}", count.index)}"
    user     = "${var.VM_USERNAME}"
    private_key = "${file("~/.ssh/id_rsa")}"

    bastion_host = "${var.BASTION_HOST_IP}"
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
    bastion_port = "22"
    bastion_user = "${var.VM_USERNAME}"
  }
 }
}