data "aws_iam_policy_document" "workerpolicy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage"
      ]
      resources = ["*"]
  }
}


resource "aws_iam_policy" "k8s-worker-policy" {
  name        = "k8s-worker-policy"
  description = "A policy that ensures worker nodes have access to needed resources"
  policy      = data.aws_iam_policy_document.workerpolicy.json
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

data "aws_iam_policy_document" "instance_assume_worker_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
} 

resource "aws_iam_role" "k8s-worker-role" {
  name = "k8s-worker-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_worker_role_policy.json
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


resource "aws_iam_role_policy_attachment" "k8s-worker-attachment" {
  role       = aws_iam_role.k8s-worker-role.name
  policy_arn = aws_iam_policy.k8s-worker-policy.arn
}


///////////////////////////////////////////////////////////////////////////////////////////////////

resource "aws_iam_instance_profile" "k8s-worker-profile" {
  name = "k8s-worker-profile"
  role = "${aws_iam_role.k8s-worker-role.name}"
}

