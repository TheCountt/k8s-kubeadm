output "master_iam_instance-profile" {
  value = aws_iam_instance_profile.k8s-master-profile.name
  description = "the iam_instance_profile to be attached to master nodes"
}