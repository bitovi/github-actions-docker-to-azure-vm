#!/bin/bash
# shellcheck disable=SC2086,SC1091

[[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] && set -x

set -e

source "$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_helpers.sh"

echo "In $(basename $0)"

GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

if [ -n "$GITHUB_HEAD_REF" ]; then
  GITHUB_BRANCH_NAME=$GITHUB_HEAD_REF
else
  GITHUB_BRANCH_NAME=$GITHUB_REF_NAME
fi

GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
echo "GITHUB_IDENTIFIER: [$GITHUB_IDENTIFIER]"

GITHUB_IDENTIFIER_SS="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier_supershort.sh)"
echo "GITHUB_IDENTIFIER SS: [$GITHUB_IDENTIFIER_SS]"

# Fixed values

ops_repo_environment="ops_repo_environment = \"deployment\""
app_org_name="app_org_name = \"${GITHUB_ORG_NAME}\""
app_repo_name="app_repo_name = \"${GITHUB_REPO_NAME}\""
app_branch_name="app_branch_name = \"${GITHUB_BRANCH_NAME}\""
app_install_root="app_install_root = \"/home/ubuntu\""
security_group_name="security_group_name = \"${GITHUB_IDENTIFIER}\""
azure_resource_identifier="azure_resource_identifier = \"${GITHUB_IDENTIFIER}\""
azure_resource_identifier_supershort="azure_resource_identifier_supershort = \"${GITHUB_IDENTIFIER_SS}\""

# Special cases

sub_domain_name=
if [ -n "$SUB_DOMAIN" ]; then
  sub_domain_name="sub_domain_name = \"$SUB_DOMAIN\""
else
  sub_domain_name="sub_domain_name = \"$GITHUB_IDENTIFIER\""
fi

#-- Application --#
app_port=$(generate_var app_port $APP_PORT)
# ops_repo_environment=$(generate_var ops_repo_environment OPS_REPO_ENVIRONMENT - Fixed
# app_org_name=$(generate_var app_org_name APP_ORG_NAME - Fixed
# app_repo_name=$(generate_var app_repo_name APP_REPO_NAME - Fixed
# app_branch_name=$(generate_var app_branch_name APP_BRANCH_NAME - Fixed
# app_install_root=$(generate_var app_install_root APP_INSTALL_ROOT - Fixed
#-- Load Balancer --#
lb_port=$(generate_var lb_port $LB_PORT)
lb_healthcheck=$(generate_var lb_healthcheck $LB_HEALTHCHECK)
#-- Logging --#
lb_access_bucket_name=$(generate_var lb_access_bucket_name $LB_LOGS_BUCKET)
#-- Security Groups --#
#security_group_name=$(generate_var security_group_name $SECURITY_GROUP_NAME) - Fixed
#-- EC2 --#
# ec2_instance_type=$(generate_var ec2_instance_type $EC2_INSTANCE_TYPE)
# ec2_iam_instance_profile=$(generate_var ec2_iam_instance_profile EC2_INSTANCE_PROFILE - Special case
#-- AWS --#
# azure_resource_identifier=$(generate_var azure_resource_identifier azure_RESOURCE_IDENTIFIER - Fixed
# azure_resource_identifier_supershort=$(generate_var azure_resource_identifier_supershort azure_RESOURCE_IDENTIFIER_SUPERSHORT - Fixed
# aws_secret_env=$(generate_var aws_secret_env $AWS_SECRET_ENV)
# aws_ami_id=$(generate_var aws_ami_id $AWS_AMI_ID)
#-- Certificates --#
# sub_domain_name=$(generate_var sub_domain_name $SUB_DOMAIN_NAME)  - Special case
domain_name=$(generate_var domain_name $DOMAIN_NAME)
root_domain=$(generate_var root_domain $ROOT_DOMAIN)
# cert_arn=$(generate_var cert_arn $CERT_ARN)
# create_root_cert=$(generate_var create_root_cert $CREATE_ROOT_CERT)
# create_sub_cert=$(generate_var create_sub_cert $CREATE_SUB_CERT)
# no_cert=$(generate_var no_cert $NO_CERT)
#-- Tags --#
additional_tags=$(generate_var additional_tags $ADDITIONAL_TAGS)
#-- ANSIBLE --##
application_mount_target=$(generate_var application_mount_target $APPLICATION_MOUNT_TARGET)
# efs_mount_target=$(generate_var efs_mount_target $EFS_MOUNT_TARGET)
data_mount_target=$(generate_var data_mount_target $DATA_MOUNT_TARGET)
# ec2_volume_size=$(generate_var ec2_volume_size $EC2_VOLUME_SIZE)


# -------------------------------------------------- #
# use heredoc to create the terraform.tfvars file

cat << TFVARS > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"
#-- Application --#
$app_port
$ops_repo_environment
$app_org_name
$app_repo_name
$app_branch_name
$app_install_root

#-- Load Balancer --#
$lb_port
$lb_healthcheck

#-- Logging --#
$lb_access_bucket_name

#-- Security Groups --#
$security_group_name

#-- AWS --#
$azure_resource_identifier
$azure_resource_identifier_supershort

#-- Certificates --#
$sub_domain_name
$domain_name
$root_domain

#-- Tags --#
$additional_tags

##-- ANSIBLE --##
$application_mount_target
$data_mount_target
TFVARS
