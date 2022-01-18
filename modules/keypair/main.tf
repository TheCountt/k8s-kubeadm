resource "aws_key_pair" "k8s-ssh_key" {
  key_name   = "k8s-kubeadm"
  public_key = file("~/k8s-kubeadm/ssh/k8s-kubeadm.id_rsa.pub")
  # public_key    = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}