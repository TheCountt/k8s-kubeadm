resource "aws_instance" "k8s-worker" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  source_dest_check           = false
  count                       = length(var.worker_ip_list)
  private_ip                  = element(var.worker_ip_list, count.index)
  vpc_security_group_ids      = [var.k8s-sg]
  associate_public_ip_address = true
  # user_data                   = "name=worker-${count.index}|pod-cidr=${var.pod_routes[count.index]}"
  key_name                    = "k8s-kubeadm"

  root_block_device {

    volume_size = 8
    volume_type = "gp3"

  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/k8s-kubeadm/ssh/k8s-kubeadm.id_rsa")
    timeout     = "5m"
  }

  tags = {
    Name = "worker-${count.index}"
  }
}

