###########################################################
################## Global Settings ########################

region              = "us-east-1"     # target AWS region
region2             = "us-east-2"     # RDS backup target AWS region
aws_admin_usernames = ["Placeholder"] # list of users to be added to the AWS admin group


###########################################################
#################### VPC Config ###########################

vpc_cidr        = "10.200.0.0/16"
vpc_name_prefix = "ex-complete-vpc-"
# vpc_instance_tenancy                = "dedicated" #does not currently work with EKS

###########################################################
################## Bastion Config #########################

bastion_name_prefix  = "ex-complete-bastion-"
bastion_ssh_user     = "ec2-user" # local user in bastion used to ssh
bastion_ssh_password = "my-password"
zarf_version         = "v0.24.0-rc4"

###########################################################
#################### EKS Config ###########################

cluster_name_prefix = "ex-complete-eks-"
eks_k8s_version     = "1.23"

###########################################################
############## Big Bang Dependencies ######################

keycloak_enabled = true
# other_addon_enabled = true


#################### Keycloak ###########################

keycloak_db_password        = "my-password"
kc_db_engine_version        = "14.1"
kc_db_family                = "postgres14" # DB parameter group
kc_db_major_engine_version  = "14"         # DB option group
kc_db_allocated_storage     = 20
kc_db_max_allocated_storage = 100
kc_db_instance_class        = "db.t4g.large"
