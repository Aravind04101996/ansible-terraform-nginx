# Ansible + Terraform
## Usecase

**Using Terraform**
```
- VPC 10.161.0.0/24.
- 3 Subnets: 1 per availability zone.
- 3 EC2 instances.
- ALB serving port 80 on each instance.
```

**Using Ansible**
```
- Deploy and configure a Nginx Docker container on each EC2 instance.
- Each nginx instance must have a different index.html (e.g. Hello, server1; Hello, server2; Hello, server3). Use Jinja2.
- Docker logs must be delivered to Cloudwatch
```
**CI**
```
- Use github actions to deploy infra in AWS using IAC 
```
------------------------------------------------------------------------------------

## Repository Information

```
- .github/workflows/* - github CI workflow to deploy infra in AWS. <br/>

- ansible-nginx-playbook/* - Ansible playbook and role to configure a Nginx Docker container on EC2 instance. <br/>

- asg-alb-infra-teraform/* - Network components (vpc, subnet, nat etc .), Auto Scaling Group with Userdata, Application Load Balancer (ALB), Security Groups, IAM Roles and Policies.

- backend/* - S3 bucket for state file storage, Dynamo DB for state locking, OIDC IAM Identity provider, IAM Role for github ci. <br/>
```