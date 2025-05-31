# AWS Configuration
eks_region     = "us-west-1"          # AWS region for EKS cluster


# Apigee Configuration
project_id               = "apigee-eks-example1"  # Replace with your actual GCP project ID
region                   = "us-west1" #GCP Region
apigee_org_name          = "apigee-eks-example1"  # Must be unique across all Apigee organizations
apigee_env_name          = "dev"                 # Environment name (dev, test, prod, etc.)
apigee_envgroup_name     = "dev-group"           # Environment group name
cluster_name             = "apigee-eks"          # EKS cluster name
apigee_namespace         = "apigee"              # Kubernetes namespace for Apigee components
apigee_version           = "1.14.2-hotfix.1"     # Apigee Hybrid version
apigee_org_display_name  = "My Company Apigee Organization"
apigee_env_display_name  = "Development Environment"
apigee_instance_name     = "apigee-instance"
apigee_cassandra_replica_count = 1    # Number of Cassandra replicas (recommended: 3 for production)


# Hostnames for Apigee Environment Group
# These are the domains that will be used to access your APIs
hostnames = [
  "api.mycompany.com",           # Production API endpoint
  "api-dev.mycompany.com"        # Development API endpoint
]

create_org=true
apigee_install=true

# Ingress Configuration
ingress_name = "apigee-ingress"
ingress_svc_annotations = {
  # AWS-specific annotations for Network Load Balancer
  "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
  "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
  "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
  
  # Optional: Add these if you need SSL termination
  # "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = "arn:aws:acm:region:account:certificate/certificate-id"
  # "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "ssl"
  # "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "443"
}

# Optional: Paths to template files if you want to use custom templates
# Uncomment and set these if you have custom templates
# overrides_template_path = "../apigee-hybrid-core/overrides-templates.yaml"
# service_template_path   = "../apigee-hybrid-core/apigee-service-template.yaml"

# Billing Configuration
billing_type = "EVALUATION"  # Options: "EVALUATION" or "PAID"
# Note: For production use, set this to "PAID"

