##### test-devops-case Build, Ship & Deployer
resource "aws_codebuild_project" "devops-case" {
  name           = "test-devops-case-deploy"
  description    = "test-devops-case test build and ship project"
  build_timeout  = "30"
  queued_timeout = "480"
  source_version = "refs/heads/main"
  service_role   = []

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0-21.04.23"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }


  # Test VPC kullanılmıştır
  
  #   vpc_config {
  #     security_group_ids = []
  #     subnets = []
  #     vpc_id  = []
  #   }

  source {
    type                = "GITHUB"
    location            = "https://github.com/omercankarlib/devops-case.git"
    git_clone_depth     = 1
    report_build_status = false
    buildspec           = "buildspec.yml"

    git_submodules_config {
      fetch_submodules = false
    }
  }

}

resource "aws_codebuild_webhook" "devops-case" {
  project_name = aws_codebuild_project.devops-case.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/main"
    }
  }
}

# ECR Part

locals {
  repos = ["api-server", "react-app"]
}


resource "aws_ecr_repository" "main" {
  for_each = toset(local.repos)
  name     = each.key

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}