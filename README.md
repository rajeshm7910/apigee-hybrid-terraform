# Apigee Hybrid Terraform

This repository contains Terraform configurations for deploying and managing Apigee Hybrid. The project supports deployment on both Google Kubernetes Engine (GKE) and Azure Kubernetes Service (AKS). The purpose is to create a evaluation Apigee instance to test the feature.


## Project Structure

```
.
├── apigee-hybrid-core/     # Core Apigee Hybrid infrastructure components
├── apigee-on-aks/         # AKS-specific deployment configurations
├── apigee-on-gke/         # GKE-specific deployment configurations
├── apigee-on-eks/         # EKS-specific deployment configurations
├── apigee-on-others/      # Install Apigee on other Kubernetes Provider/Access to kubecontext
└── diagram/               # Architecture diagrams and documentation
```

## Prerequisites

- Terraform >= 1.0.0
- Google Cloud SDK
- kubectl
- gcloud CLI
- Helm Chart >= 3.15+
- Access to a GCP project with appropriate permissions
- For AKS deployments: Azure CLI and access to an Azure subscription

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/apigee-hybrid-terraform.git
   cd apigee-hybrid-terraform
   ```

2. Choose your deployment target:
   - For GKE deployment: Navigate to `apigee-on-gke/`
   - For AKS deployment: Navigate to `apigee-on-aks/`
   - For EKS deployment: Navigate to `apigee-on-eks/`
   - For other Kubernetes Provider deployment: Navigate to `apigee-on-others/`

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Configure your variables:
   - Copy `terraform.tfvars.example` to `terraform.tfvars`
   - Update the variables with your specific values

5. Apply the configuration:
   ```bash
   terraform plan
   terraform apply
   ```

## Components

### Core Infrastructure (`apigee-hybrid-core/`)

The core module provides the fundamental infrastructure components required for Apigee Hybrid, including:
- IAM configurations
- Service accounts
- Core GCP resources

### GKE Deployment (`apigee-on-gke/`)

Specific configurations for deploying Apigee Hybrid on Google Kubernetes Engine, including:
- GKE cluster configuration
- Apigee runtime components
- Network configurations
- Load balancer setup

### AKS Deployment (`apigee-on-aks/`)

Configurations for deploying Apigee Hybrid on Azure Kubernetes Service, including:
- AKS cluster setup
- Cross-cloud networking
- Hybrid connectivity
- Azure-specific configurations



## Maintenance

### Upgrading

1. Review the release notes for the target version
2. Update the Apigee runtime version in your configuration
3. Apply the changes using Terraform

### Backup and Recovery

- Regular backups of the Apigee runtime data
- Terraform state backup
- Configuration version control

## Troubleshooting

Common issues and their solutions:

1. **Cluster Creation Fails**
   - Check IAM permissions
   - Verify quota availability
   - Review network configurations

2. **Apigee Runtime Issues**
   - Check pod status: `kubectl get pods -n apigee`
   - Review logs: `kubectl logs -n apigee`
   - Verify connectivity to Apigee control plane

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the terms of the license included in the repository.

## Support

For issues and feature requests, please create an issue in the GitHub repository.

## Additional Resources

- [Apigee Hybrid Documentation](https://cloud.google.com/apigee/docs/hybrid)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [AKS Documentation](https://docs.microsoft.com/azure/aks)
