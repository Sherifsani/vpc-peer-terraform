# Terraform VPC Peering and EC2 Setup

This Terraform configuration creates two VPCs, sets up VPC peering between them, and launches two EC2 instances (one in each VPC). The instances are configured to communicate with each other using ICMP (ping) through security groups and route tables.

## Resources Created

1. **VPCs**:
   - `vpc-a`: CIDR `10.0.0.0/16`
   - `vpc-b`: CIDR `20.0.0.0/16`

2. **Subnets**:
   - `subnet_a` in `vpc-a`
   - `subnet_b` in `vpc-b`

3. **Internet Gateways**:
   - Attached to each VPC for external access.

4. **Route Tables**:
   - Configured to route traffic through the VPC peering connection.

5. **Security Groups**:
   - Allow ICMP traffic between the two instances.

6. **EC2 Instances**:
   - `server-a` in `subnet_a` (VPC A)
   - `server-b` in `subnet_b` (VPC B)

7. **VPC Peering Connection**:
   - Allows communication between `vpc-a` and `vpc-b`.

## Usage

1. **Prerequisites**:
   - Terraform installed on your local machine.
   - AWS credentials configured.

2. **Steps**:
   - Initialize Terraform: ```bash
   terraform init
    ```
   - Apply the configuration: `terraform apply`

3. **Testing**:
   - SSH into `server-a` and ping `server-b` using its private IP address to verify the connection.

## Notes

- Ensure the SSH key specified (`key_name`) exists in your AWS account.
- The instances must use their **private IP addresses** for communication through the peering connection.

## Cleanup

To destroy all resources, run:

```bash
terraform destroy
```

---
