terraform {
  cloud {
    organization = "aws-devops-ai"
    workspaces {
      name = "aws-cloudleader-demo"
    }
  }
}