# Apigee Hybrid on Existing Kubernetes Clusters

This directory contains Terraform configurations for deploying Apigee Hybrid on an existing Kubernetes cluster. This setup assumes that you already have a Kubernetes cluster running and properly configured with the necessary node pools for Apigee Hybrid.

## Prerequisites

1. **Existing Kubernetes Cluster**:
   - A running Kubernetes cluster (version 1.29 or later)
   - At least two node pools:
     - Runtime node pool for Apigee runtime components with name `apigeerun`
     - Data node pool for Apigee data components with name `apigeedata`
   - Proper network configuration for the cluster
   - Load balancer configured for ingress

2. **Kubernetes Access**:
   - `kubectl` configured to access your cluster
   - `KUBECONFIG` environment variable set or config file in `~/.kube/config`
   - Proper RBAC permissions in the cluster

3. **Google Cloud Setup**:
   - Google Cloud SDK installed and configured
   - Project with Apigee API enabled
   - Service account with necessary permissions
   - Organization Policy allowing service account key creation

4. **Required Tools**:
   - Terraform >= 1.0.0
   - Helm >= 3.10.0
   - kubectl
   - gcloud CLI

## Configuration

1. **Set up your variables**:
   Create a `terraform.tfvars` file with your specific values:

   ```hcl
   project_id = "apigee-gke-example3"
   region     = "us-central1"        # Default region, change if needed
   apigee_org_name          = "apigee-gke-example3"
   apigee_env_name          = "dev"
   apigee_envgroup_name     = "dev-group"
   cluster_name             = "apigee"
   apigee_namespace         = "apigee"
   apigee_version           = "1.14.2-hotfix.1"
   apigee_org_display_name  = "My Company Apigee Organization"
   apigee_env_display_name  = "Development Environment"
   apigee_instance_name     = "apigee-instance"
   apigee_cassandra_replica_count = 1

   hostnames = [
   "api.mycompany.com",           # Production API endpoint
   "api-dev.mycompany.com"        # Development API endpoint
   ]
   ingress_name = "apigee-ingress"

   ```

2. **Verify Kubernetes Access**:
   ```bash
   kubectl get nodes
   ```

3. **Verify Node Pools**:
   ```bash
   kubectl get nodes --show-labels
   ```
   Ensure you have nodes with the appropriate labels for Apigee runtime and data components.

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the Plan**:
   ```bash
   terraform plan
   ```

3. **Apply the Configuration**:
   ```bash
   terraform apply
   ```

## What Gets Deployed

1. **Apigee Organization**:
   - Creates or uses existing Apigee organization
   - Sets up environment and environment group
   - Configures runtime settings

2. **Kubernetes Resources**:
   - Creates necessary namespaces
   - Deploys Apigee runtime components
   - Configures service accounts and RBAC
   - Sets up ingress and load balancing

3. **SSL/TLS Configuration**:
   - Generates or uses provided SSL certificates
   - Configures TLS for the runtime

## Verification

1. **Check Apigee Components**:
   ```bash
   kubectl get pods -n apigee
   ```

2. **Verify Environment Group**:
   ```bash
   gcloud apigee envgroups list --organization=$PROJECT_ID
   ```

3. **Test API Access**:
   ```bash
   curl -v https://$APIGEE_RUNTIME_HOSTNAME
   ```

## Cleanup

1. **Remove Apigee Components**:
   ```bash
   helm uninstall apigee-hybrid -n apigee
   ```

2. **Destroy Terraform Resources**:
   ```bash
   terraform destroy
   ```

3. **Clean Up Local Files**:
   ```bash
   rm -rf output/${PROJECT_ID}/
   ```

## Troubleshooting

1. **Kubernetes Connection Issues**:
   - Verify `kubectl` configuration
   - Check cluster accessibility
   - Ensure proper RBAC permissions

2. **Apigee Deployment Issues**:
   - Check pod status and logs
   - Verify node pool labels
   - Review Apigee runtime logs

3. **SSL/TLS Issues**:
   - Verify certificate validity
   - Check ingress configuration
   - Review TLS settings

## Additional Resources

- [Apigee Hybrid Documentation](https://cloud.google.com/apigee/docs/hybrid)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Helm Documentation](https://helm.sh/docs/) 