# ECS Infrastructure with WAF and Auto-scaling

## Overview
This infrastructure deploys a containerized application on AWS ECS with configurable networking, WAF protection, and auto-scaling capabilities.

## Architecture Components

### Networking Module

- The networking module creates a flexible VPC architecture with toggleable private/public subnet configuration.

- Here you can sprcify your vpc CIDR block and the subnet CIDR blocks are generated dynamically for you.

- Enabling the private subnet follows ECS best practices to protect the tasks from direct external access. Its outbound traffic is routed through any NAT gateway that you have associated with that private subnet. Setting this to false enables the `Assign public IP address` optiom to the tasks and each task is networked in the public subnet, and has its own public IP address for direct communication with the internet.

```hcl
module "networking" {
  enable_private_networking = true/false  # Toggle private subnet setup
}
```
### Load Balancer Module
Manages the Application Load Balancer (ALB) configuration.

- The ALB must be deployed across minimum 2 subnets which is the default
- Subnets must be in different Availability Zones
- Public subnet placement for internet accessibility
- Route tables for both public and private subnets. This resolves the issue that prevented the ECS tasks from reaching a "RUNNING" state

### ECS Module
- Deploys and manages the ECS cluster, service, and tasks.
- Uses private subnets when private networking enabled
- Uses public subnets with public IPs when private networking disabled

### WAF Configuration
Implements Web Application Firewall protection with a CAPTCHA-based WAF rate limit and a blanket rate-based rule. 
- The CAPTCHA rule challenges requests when a single IP makes certain number of requests per minute, and the blanket rate-based rule blocks requests if an IP exceeds certain number of requests in 5 minutes, providing an additional layer of protection in case the CAPTCHA is bypassed


### Auto-scaling Configuration
- Implements request-based scaling using ALBRequestCountPerTarget to track requests per target per minute and scales based on that
- Scales up on average CPU usage of 75%
- Scales up on average memory usage of 70%