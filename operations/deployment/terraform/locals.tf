# resource "random_integer" "az_select" {
#   min = 0
#   max = length(data.aws_ec2_instance_type_offerings.region_azs.locations) - 1

#   lifecycle {
#     ignore_changes = all
#   }
# }

locals {
  azure_tags = {
    OperationsRepo            = "bitovi/github-actions-docker-to-azure-vm/operations/${var.ops_repo_environment}"
    AWSResourceIdentifier     = "${var.azure_resource_identifier}"
    GitHubOrgName             = "${var.app_org_name}"
    GitHubRepoName            = "${var.app_repo_name}"
    GitHubBranchName          = "${var.app_branch_name}"
    GitHubAction              = "bitovi/github-actions-docker-to-azure-vm"
    OperationsRepoEnvironment = "deployment"
    created_with              = "terraform"
  }
}
