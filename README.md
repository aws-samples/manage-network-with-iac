<!-- BEGIN_TF_DOCS -->
## Manage your Network sing Infrastructure as Code (Workshop code)

This repository is the code base for the AWS Workshop [Manage your Network using Infrastructure as Code](https://catalog.workshops.aws/manage-network-using-iac/en-US).

When you add applications to your AWS environment, with tens or hundreds of VPCs, management (traffic inspection, access to shared services, DNS resolution, or simply connectivity) can become complex. In the workshop, you will use Terraform to explore how to manage applications within one AWS Region. We will discuss the benefits of centralizing services using AWS Transit Gateway, and how you can create a global network between AWS Regions and on-premises environments using code.

Several public modules (created and maintained by AWS) are used:

* [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest)
* [Hub and Spoke module](https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest).
* [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest)

**Note**: The final versions of the code at the end of each lab can be found in the **final\_code** folder.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 4.67.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | AWS Regions to build our environment. | `map(string)` | <pre>{<br>  "oregon": "us-west-2"<br>}</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"manage-network-iac"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `any` | <pre>{<br>  "oregon": {<br>    "vpc1": {<br>      "cidr_block": "10.0.0.0/24",<br>      "cwan_subnet_cidrs": [<br>        "10.0.0.96/28",<br>        "10.0.0.112/28"<br>      ],<br>      "endpoints_subnet_cidrs": [<br>        "10.0.0.32/28",<br>        "10.0.0.48/28"<br>      ],<br>      "instance_type": "t2.micro",<br>      "number_azs": 2,<br>      "workload_subnet_cidrs": [<br>        "10.0.0.0/28",<br>        "10.0.0.16/28"<br>      ]<br>    }<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->