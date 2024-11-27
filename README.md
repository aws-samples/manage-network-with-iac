## Manage your Network sing Infrastructure as Code (Workshop code)

This repository is the code base for the AWS Workshop [Manage your Network using Infrastructure as Code](https://catalog.workshops.aws/manage-network-using-iac/en-US).

When you add applications to your AWS environment, with tens or hundreds of VPCs, management (traffic inspection, access to shared services, DNS resolution, or simply connectivity) can become complex. In the workshop, you will use Terraform to explore how to manage applications within one AWS Region. We will discuss the benefits of centralizing services using AWS Transit Gateway, and how you can create a global network between AWS Regions and on-premises environments using code.

Several public modules (created and maintained by AWS) are used:

* [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest)
* [Hub and Spoke module](https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest).
* [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest)

**Note**: The final version of each lab can be found in the **final_code** folder.

## Prerequisites - if you follow the workshop outside AWS Hosted Events

* An AWS account with an IAM user with the appropriate permissions.
* Terraform installed.

## Code Principles

* Writing DRY (Do No Repeat Yourself) code using a modular design pattern.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
