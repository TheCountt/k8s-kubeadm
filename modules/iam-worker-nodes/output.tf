output "worker_iam_instance-profile" {
  value       = aws_iam_instance_profile.k8s-worker-profile.name
  description = "the iam_instance_profile to be attached to worker nodes"
}