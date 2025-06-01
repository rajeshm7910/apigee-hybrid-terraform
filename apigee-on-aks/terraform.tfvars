# Azure Configuration
azure_location = "eastus"  # Using eastus2 for better availability

# GCP Configuration
gcp_project_id = "apigee-aks-example1"
gcp_region     = "us-central1"

# Apigee Configuration
apigee_org_name      = "apigee-aks-example1"  # Same as gcp_project_id
apigee_env_name      = "dev"
apigee_envgroup_name = "dev-group"
apigee_namespace     = "apigee"
apigee_version       = "1.14.2-hotfix.1"
apigee_cassandra_replica_count = 1

# Hostnames for Apigee Environment Group
hostnames = [
  "api.example.com",
  "api-dev.example.com"
]

create_org=true
apigee_install=false


# Ingress Configuration
ingress_name = "apigee-ingress"
ingress_svc_annotations = {
  # Uncomment and modify these based on your cloud provider
  # For AWS:
  # "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  # "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
  
  # For GCP:
  # "cloud.google.com/neg" = "{\"ingress\": true}"
  # "cloud.google.com/load-balancer-type" = "internal"
  
  # For Azure:
  # "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
  # "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = "your-subnet-name"
}
