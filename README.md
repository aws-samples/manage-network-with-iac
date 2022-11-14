<!-- BEGIN_TF_DOCS -->
## Mange your AWS Network (multi-region) using Infrastructure as Code

This repository builds two Hub and Spoke architectures using AWS Transit Gateway in the following AWS Regions: Oregon (*us-west-2*) and Stockholm (*eu-north-1*). The purpose of the repository is to show how you can leverage Terraform modules (created and maintained by AWS) to manage at scale your AWS networking infrastructure when working with several VPCs in multi-region environments. The public modules used (published in the Terraform Registry) are the following ones:

* [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest)
* [Hub and Spoke module](https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest). This modules uses the [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest) to build a AWS Network Firewall resource as inspection layer.

This example builds the following resources (same in both AWS Regions indicated above):

* Hub and Spoke architecture with AWS Transit Gateway - with a central Inspection VPC (with AWS Network Firewall) to inspect the north-south traffic, and a Shared Services VPC to place VPC endpoints.
* 2 Spoke VPCs - one in production and other one in non-production routing domains.
* AWS Systems Manager VPC endpoints centralized in the Shared Services VPC - to access the EC2 instances created privately using Systems Manager Session Manager. The Private Hosted Zones to allow DNS resolution are also created.
* EC2 instances in each Spoke VPC to test end-to-end connectivity - check the *firewall\_policy\_nvirginia.tf* and *firewall\_policy\_ireland.tf* files to understand which traffic is allowed in each AWS Region.

**Note**: Connectivity between AWS Regions is a proposed exercise to the user of this repository. We will work in adding code example in the following months.

## Prerequisites
* An AWS account with an IAM user with the appropriate permissions
* Terraform installed

## Code Principles:
* Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Deployment and cleanup
* Clone the repository
* Due to dependencies in between the modules used, you first need to deploy the AWS Transit Gateways, Managed Prefix Lists, and Spoke VPCs: `terraform apply -target="module.oregon_spoke_vpcs" -target="module.stockholm_spoke_vpcs" -target="module.hub_spoke_oregon.aws_ec2_transit_gateway.tgw" -target="module.hub_spoke_stockholm.aws_ec2_transit_gateway.tgw" -target="aws_ec2_managed_prefix_list.oregon_network" -target="aws_ec2_managed_prefix_list.stockholm_network"`
* Once these resources are created, now you can apply the rest of resources: `terraform apply`
* Remember to clean up after your work is complete. You can do that by doing `terraform destroy`. Note that this command will delete all the resources previously created by Terraform.

**Note** EC2 instances, VPC endpoints and AWS Network Firewall endpoints will be created in all the Availability Zones where a subnet is created. Take that into account when doing your tests from a cost-perspective. The default number of AZs used in each VPC is 2 (to follow best-practices) but you can change that in the *variables.tf* file for the Spoke VPCs, and in the *main.tf* file for the Hub and Spoke central VPCs.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.28.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.awsoregon"></a> [aws.awsoregon](#provider\_aws.awsoregon) | 4.33.0 |
| <a name="provider_aws.awsstockholm"></a> [aws.awsstockholm](#provider\_aws.awsstockholm) | 4.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub_spoke_oregon"></a> [hub\_spoke\_oregon](#module\_hub\_spoke\_oregon) | aws-ia/network-hubandspoke/aws | 1.0.1 |
| <a name="module_hub_spoke_stockholm"></a> [hub\_spoke\_stockholm](#module\_hub\_spoke\_stockholm) | aws-ia/network-hubandspoke/aws | 1.0.1 |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_oregon_compute"></a> [oregon\_compute](#module\_oregon\_compute) | ./modules/compute | n/a |
| <a name="module_oregon_phz"></a> [oregon\_phz](#module\_oregon\_phz) | ./modules/phz | n/a |
| <a name="module_oregon_spoke_vpcs"></a> [oregon\_spoke\_vpcs](#module\_oregon\_spoke\_vpcs) | aws-ia/vpc/aws | = 3.0.1 |
| <a name="module_oregon_vpc_endpoints"></a> [oregon\_vpc\_endpoints](#module\_oregon\_vpc\_endpoints) | ./modules/vpc_endpoints | n/a |
| <a name="module_stockholm_compute"></a> [stockholm\_compute](#module\_stockholm\_compute) | ./modules/compute | n/a |
| <a name="module_stockholm_phz"></a> [stockholm\_phz](#module\_stockholm\_phz) | ./modules/phz | n/a |
| <a name="module_stockholm_spoke_vpcs"></a> [stockholm\_spoke\_vpcs](#module\_stockholm\_spoke\_vpcs) | aws-ia/vpc/aws | = 3.0.1 |
| <a name="module_stockholm_vpc_endpoints"></a> [stockholm\_vpc\_endpoints](#module\_stockholm\_vpc\_endpoints) | ./modules/vpc_endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_managed_prefix_list.oregon_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list.stockholm_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list_entry.oregon_entry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry) | resource |
| [aws_ec2_managed_prefix_list_entry.stockholm_entry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry) | resource |
| [aws_networkfirewall_firewall_policy.oregon_anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.stockholm_anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.oregon_allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.oregon_drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.stockholm_allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.stockholm_drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | AWS regions to spin up resources. | `map(string)` | <pre>{<br>  "oregon": "us-west-2",<br>  "stockholm": "eu-north-1"<br>}</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project Identifier. | `string` | `"net324"` | no |
| <a name="input_oregon_spoke_vpcs"></a> [oregon\_spoke\_vpcs](#input\_oregon\_spoke\_vpcs) | Information about the VPCs to create in us-west-2. | `any` | <pre>{<br>  "non-prod": {<br>    "cidr_block": "10.0.1.0/24",<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.0.1.0/28",<br>      "10.0.1.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.0.1.32/28",<br>      "10.0.1.48/28"<br>    ],<br>    "type": "nonprod"<br>  },<br>  "prod": {<br>    "cidr_block": "10.0.0.0/24",<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.0.0.0/28",<br>      "10.0.0.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.0.0.32/28",<br>      "10.0.0.48/28"<br>    ],<br>    "type": "prod"<br>  }<br>}</pre> | no |
| <a name="input_stockholm_spoke_vpcs"></a> [stockholm\_spoke\_vpcs](#input\_stockholm\_spoke\_vpcs) | Information about the VPCs to create in eu-north-1. | `any` | <pre>{<br>  "non-prod": {<br>    "cidr_block": "10.1.1.0/24",<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.1.1.0/28",<br>      "10.1.1.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.1.1.32/28",<br>      "10.1.1.48/28"<br>    ],<br>    "type": "nonprod"<br>  },<br>  "prod": {<br>    "cidr_block": "10.1.0.0/24",<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.1.0.0/28",<br>      "10.1.0.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.1.0.32/28",<br>      "10.1.0.48/28"<br>    ],<br>    "type": "prod"<br>  }<br>}</pre> | no |
| <a name="input_supernet"></a> [supernet](#input\_supernet) | AWS Region Supernet CIDR blocks. | `map(string)` | <pre>{<br>  "oregon": "10.0.0.0/16",<br>  "stockholm": "10.1.0.0/16"<br>}</pre> | no |
| <a name="input_transit_gateway_asn"></a> [transit\_gateway\_asn](#input\_transit\_gateway\_asn) | Amazon Side ASNs to apply in the Transit Gateways. | `map(string)` | <pre>{<br>  "oregon": 65050,<br>  "stockholm": 65051<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oregon"></a> [oregon](#output\_oregon) | Resources deployed in Oregon (us-west-2). |
| <a name="output_stockholm"></a> [stockholm](#output\_stockholm) | Resources deployed in Stockholm (eu-north-1). |
<!-- END_TF_DOCS -->