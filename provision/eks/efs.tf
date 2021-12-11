resource "aws_efs_file_system" "cloud_native_workstation" {
  creation_token = "${var.eks_cluster_name}"
  encrypted      = true
  tags           = var.aws_tags
}

resource "aws_efs_mount_target" "mount0" {
  file_system_id = aws_efs_file_system.cloud_native_workstation.id
  subnet_id      = module.vpc.private_subnets[0]
  security_groups = [
    module.eks.cluster_primary_security_group_id,
    module.eks.worker_security_group_id,
  ]
}

resource "aws_efs_mount_target" "mount1" {
  file_system_id = aws_efs_file_system.cloud_native_workstation.id
  subnet_id      = module.vpc.private_subnets[1]
  security_groups = [
    module.eks.cluster_primary_security_group_id,
    module.eks.worker_security_group_id,
  ]
}

resource "aws_iam_role" "eks_efs" {
  # https://stackoverflow.com/questions/66405794/not-authorized-to-perform-stsassumerolewithwebidentity-403
  name = "${var.eks_cluster_name}-eks-efs"
  tags = var.aws_tags

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": format(
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:%s",
            replace(
              "${module.eks.cluster_oidc_issuer_url}",
              "https://",
              "oidc-provider/"
            )
          )
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            format(
              "%s:sub",
              trimprefix(
                "${module.eks.cluster_oidc_issuer_url}",
                "https://"
              )
            ): "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "efs" {
  name = "${var.eks_cluster_name}-eks-efs"
  tags = var.aws_tags

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "elasticfilesystem:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_efs_attach" {
  role       = aws_iam_role.eks_efs.name
  policy_arn = aws_iam_policy.efs.arn
}
