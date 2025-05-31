# GCP Configuration
project_id = "apigee-gke-example7"
region     = "us-central1"

# Apigee Configuration
apigee_org_name          = "apigee-gke-example7" #Same as Projectid
apigee_env_name          = "dev"
apigee_envgroup_name     = "dev-group"
apigee_namespace         = "apigee"
apigee_version           = "1.14.2-hotfix.1"
apigee_org_display_name  = "Apigee GKE Example Organization"
apigee_env_display_name  = "Development Environment"
apigee_instance_name     = "apigee-instance"
apigee_cassandra_replica_count = 3

# Hostnames for Apigee Environment Group
hostnames = [
  "api.example.com",
  "api-dev.example.com"
]

# Ingress Configuration
ingress_name = "apigee-ingress"
ingress_svc_annotations = {
  # "cloud.google.com/neg" = "{\"ingress\": true}"
  # "cloud.google.com/load-balancer-type" = "Internal"
}

create_org=true
apigee_install=true

# Optional: Paths to template files if you want to use custom templates
# overrides_template_path = "path/to/overrides-template.yaml"
# service_template_path   = "path/to/service-template.yaml"

# Billing Configuration
billing_type = "EVALUATION"  # or "PAID" 
