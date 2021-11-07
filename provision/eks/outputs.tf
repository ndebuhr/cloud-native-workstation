output "efs_fs_id" {
  value       = aws_efs_file_system.cloud_native_workstation.id
  description = "The AWS EFS ID"
}

output "efs_role_arn" {
    value       = aws_iam_role.eks_efs.arn
    description = "AWS ARN for EFS management"
}