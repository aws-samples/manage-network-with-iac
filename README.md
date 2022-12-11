<!-- BEGIN_TF_DOCS -->
## Manage your Network sing Infrastructure as Code (Workshop code)

This repository is the code base for the AWS Workshop [Manage your Network using Infrastructure as Code](https://catalog.workshops.aws/manage-network-using-iac/en-US).

When you add applications to your AWS environment, with tens or hundreds of VPCs, management (traffic inspection, access to shared services, DNS resolution, or simply connectivity) can become complex. In the workshop, you will use Terraform to explore how to manage applications within one AWS Region. We will discuss the benefits of centralizing services using AWS Transit Gateway, and how you can create a global network between AWS Regions and on-premises environments using code.

Several public modules (created and maintained by AWS) are used:

* [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest)
* [Hub and Spoke module](https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest).
* [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest)

**Note**: The final versions of the *main.tf* and *outputs.tf* files at the end of each lab can be found in the **final\_code** folder.

## Prerequisites - if you follow the workshop outside AWS hosted events
* An AWS account with an IAM user with the appropriate permissions.
* Terraform installed.

## Code Principles:
* Writing DRY (Do No Repeat Yourself) code using a modular design pattern.

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

No modules.

## Resources

| Name | Type |
|------|------|
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
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project Identifier. | `string` | `"manage-network-iac"` | no |
| <a name="input_oregon_spoke_vpcs"></a> [oregon\_spoke\_vpcs](#input\_oregon\_spoke\_vpcs) | Information about the VPCs to create in us-west-2. | `any` | <pre>{<br>  "non-prod": {<br>    "cidr_block": "10.0.1.0/24",<br>    "cwan_subnet_cidrs": [<br>      "10.0.1.64/28",<br>      "10.0.1.80/28"<br>    ],<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.0.1.0/28",<br>      "10.0.1.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.0.1.32/28",<br>      "10.0.1.48/28"<br>    ],<br>    "type": "nonprod"<br>  },<br>  "prod": {<br>    "cidr_block": "10.0.0.0/24",<br>    "cwan_subnet_cidrs": [<br>      "10.0.0.64/28",<br>      "10.0.0.80/28"<br>    ],<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.0.0.0/28",<br>      "10.0.0.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.0.0.32/28",<br>      "10.0.0.48/28"<br>    ],<br>    "type": "prod"<br>  }<br>}</pre> | no |
| <a name="input_stockholm_spoke_vpcs"></a> [stockholm\_spoke\_vpcs](#input\_stockholm\_spoke\_vpcs) | Information about the VPCs to create in eu-north-1. | `any` | <pre>{<br>  "non-prod": {<br>    "cidr_block": "10.1.1.0/24",<br>    "cwan_subnet_cidrs": [<br>      "10.1.1.64/28",<br>      "10.1.1.80/28"<br>    ],<br>    "instance_type": "t3.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.1.1.0/28",<br>      "10.1.1.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.1.1.32/28",<br>      "10.1.1.48/28"<br>    ],<br>    "type": "nonprod"<br>  },<br>  "prod": {<br>    "cidr_block": "10.1.0.0/24",<br>    "cwan_subnet_cidrs": [<br>      "10.1.0.64/28",<br>      "10.1.0.80/28"<br>    ],<br>    "instance_type": "t3.micro",<br>    "number_azs": 2,<br>    "private_subnet_cidrs": [<br>      "10.1.0.0/28",<br>      "10.1.0.16/28"<br>    ],<br>    "tgw_subnet_cidrs": [<br>      "10.1.0.32/28",<br>      "10.1.0.48/28"<br>    ],<br>    "type": "prod"<br>  }<br>}</pre> | no |
| <a name="input_supernet"></a> [supernet](#input\_supernet) | AWS Region Supernet CIDR blocks. | `map(string)` | <pre>{<br>  "oregon": "10.0.0.0/16",<br>  "stockholm": "10.1.0.0/16"<br>}</pre> | no |
| <a name="input_transit_gateway_asn"></a> [transit\_gateway\_asn](#input\_transit\_gateway\_asn) | Amazon Side ASNs to apply in the Transit Gateways. | `map(string)` | <pre>{<br>  "oregon": 65050,<br>  "stockholm": 65051<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->