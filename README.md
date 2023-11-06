<!-- BEGIN_TF_DOCS -->
## NET303 - How to manage your network using infrastructure as code

This repository is the code base for the AWS Workshop [Manage your Network using Infrastructure as Code](https://catalog.workshops.aws/manage-network-using-iac/en-US).

As workloads increase on AWS and you expand to different AWS Regions, creating and managing network elements can be challenging. In this builders’ session, learn about recommended approaches to using infrastructure as code (IaC) to manage multi-Region networks. Also find out tips for how to deal with migrations when modernizing your infrastructure. This session uses Terraform as the IaC framework.

Several public modules (created and maintained by AWS) are used:

* [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest)
* [Hub and Spoke module](https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest).
* [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest)

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 5.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 5.22.0 |
| <a name="provider_aws.awsoregon"></a> [aws.awsoregon](#provider\_aws.awsoregon) | = 5.22.0 |
| <a name="provider_aws.awstokyo"></a> [aws.awstokyo](#provider\_aws.awstokyo) | = 5.22.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_oregon_compute"></a> [oregon\_compute](#module\_oregon\_compute) | ./modules/compute | n/a |
| <a name="module_oregon_hubspoke"></a> [oregon\_hubspoke](#module\_oregon\_hubspoke) | aws-ia/network-hubandspoke/aws | 3.2.0 |
| <a name="module_oregon_vpcs"></a> [oregon\_vpcs](#module\_oregon\_vpcs) | aws-ia/vpc/aws | 4.4.1 |
| <a name="module_prefix_lists"></a> [prefix\_lists](#module\_prefix\_lists) | ./modules/prefix_lists | n/a |
| <a name="module_tokyo_compute"></a> [tokyo\_compute](#module\_tokyo\_compute) | ./modules/compute | n/a |
| <a name="module_tokyo_hubspoke"></a> [tokyo\_hubspoke](#module\_tokyo\_hubspoke) | aws-ia/network-hubandspoke/aws | 3.2.0 |
| <a name="module_tokyo_vpcs"></a> [tokyo\_vpcs](#module\_tokyo\_vpcs) | aws-ia/vpc/aws | 4.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_peering_attachment.tgw_peering](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.oregon_nonprod_to_tokyo_prod_blackhole](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.oregon_prod_to_tokyo_nonprod_blackhole](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.oregon_to_tokyo_nonprod](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.oregon_to_tokyo_prod](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.tokyo_nonprod_to_oregon_prod_blackhole](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.tokyo_prod_to_oregon_nonprod_blackhole](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.tokyo_to_oregon_nonprod](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_prefix_list_reference.tokyo_to_oregon_prod](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_prefix_list_reference) | resource |
| [aws_ec2_transit_gateway_route_table.oregon_tgw_rt_peering](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.tokyo_tgw_rt_peering](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.oregon_tgw_rt_peering_assoc](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.tokyo_tgw_rt_peering_assoc](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.oregon_tgw_rt_peering_prop](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.tokyo_tgw_rt_peering_prop](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_networkfirewall_firewall_policy.oregon_anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.tokyo_anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.oregon_allow_domains](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.oregon_drop_remote](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.tokyo_allow_domains](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.tokyo_drop_remote](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkmanager_core_network) | resource |
| [aws_networkmanager_core_network_policy_attachment.core_network_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkmanager_core_network_policy_attachment) | resource |
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/resources/networkmanager_global_network) | resource |
| [aws_networkmanager_core_network_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/5.22.0/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | AWS Regions to build our environment. | `map(string)` | <pre>{<br>  "oregon": "us-west-2",<br>  "tokyo": "ap-northeast-1"<br>}</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"net303"` | no |
| <a name="input_inspection_vpc"></a> [inspection\_vpc](#input\_inspection\_vpc) | Inspection VPC parameters. | `map(any)` | <pre>{<br>  "cidr_block": "10.100.0.0/24",<br>  "cwan_subnet_netmask": 28,<br>  "endpoints_subnet_netmask": 28,<br>  "number_azs": 2,<br>  "public_subnet_netmask": 28,<br>  "tgw_subnet_netmask": 28<br>}</pre> | no |
| <a name="input_routing_domains"></a> [routing\_domains](#input\_routing\_domains) | Routing domains. | `list(string)` | <pre>[<br>  "prod",<br>  "nonprod",<br>  "shared"<br>]</pre> | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `any` | <pre>{<br>  "oregon": {<br>    "vpc1": {<br>      "cidr_block": "10.0.0.0/24",<br>      "endpoints_subnet_cidrs": [<br>        "10.0.0.32/28",<br>        "10.0.0.48/28"<br>      ],<br>      "instance_type": "t2.micro",<br>      "number_azs": 2,<br>      "routing_domain": "prod",<br>      "tgw_subnet_cidrs": [<br>        "10.0.0.64/28",<br>        "10.0.0.80/28"<br>      ],<br>      "workload_subnet_cidrs": [<br>        "10.0.0.0/28",<br>        "10.0.0.16/28"<br>      ]<br>    },<br>    "vpc2": {<br>      "cidr_block": "10.0.1.0/24",<br>      "endpoints_subnet_cidrs": [<br>        "10.0.1.32/28",<br>        "10.0.1.48/28"<br>      ],<br>      "instance_type": "t2.micro",<br>      "number_azs": 2,<br>      "routing_domain": "prod",<br>      "tgw_subnet_cidrs": [<br>        "10.0.1.64/28",<br>        "10.0.1.80/28"<br>      ],<br>      "workload_subnet_cidrs": [<br>        "10.0.1.0/28",<br>        "10.0.1.16/28"<br>      ]<br>    },<br>    "vpc3": {<br>      "cidr_block": "10.0.2.0/24",<br>      "endpoints_subnet_cidrs": [<br>        "10.0.2.32/28",<br>        "10.0.2.48/28"<br>      ],<br>      "instance_type": "t2.micro",<br>      "number_azs": 2,<br>      "routing_domain": "nonprod",<br>      "tgw_subnet_cidrs": [<br>        "10.0.2.64/28",<br>        "10.0.2.80/28"<br>      ],<br>      "workload_subnet_cidrs": [<br>        "10.0.2.0/28",<br>        "10.0.2.16/28"<br>      ]<br>    }<br>  },<br>  "tokyo": {<br>    "vpc1": {<br>      "cidr_block": "10.1.0.0/24",<br>      "endpoints_subnet_cidrs": [<br>        "10.1.0.32/28",<br>        "10.1.0.48/28"<br>      ],<br>      "instance_type": "t3.micro",<br>      "number_azs": 2,<br>      "routing_domain": "prod",<br>      "tgw_subnet_cidrs": [<br>        "10.1.0.64/28",<br>        "10.1.0.80/28"<br>      ],<br>      "workload_subnet_cidrs": [<br>        "10.1.0.0/28",<br>        "10.1.0.16/28"<br>      ]<br>    },<br>    "vpc2": {<br>      "cidr_block": "10.1.1.0/24",<br>      "endpoints_subnet_cidrs": [<br>        "10.1.1.32/28",<br>        "10.1.1.48/28"<br>      ],<br>      "instance_type": "t3.micro",<br>      "number_azs": 2,<br>      "routing_domain": "nonprod",<br>      "tgw_subnet_cidrs": [<br>        "10.1.1.64/28",<br>        "10.1.1.80/28"<br>      ],<br>      "workload_subnet_cidrs": [<br>        "10.1.1.0/28",<br>        "10.1.1.16/28"<br>      ]<br>    }<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->