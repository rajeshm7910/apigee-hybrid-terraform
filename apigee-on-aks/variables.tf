variable "azure_location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for Apigee control plane resources"
  type        = string
  default     = "us-central1"
}

variable "apigee_org_name" {
  description = "The name of the Apigee organization (typically the GCP Project ID)."
  type        = string
  # This will be used as the org_name in overrides.yaml if provided,
  # otherwise the core module defaults to using var.gcp_project_id.
}

variable "apigee_env_name" {
  description = "The name of the Apigee environment"
  type        = string
  default     = "dev"
}

variable "apigee_envgroup_name" {
  description = "The name of the Apigee environment group"
  type        = string
  default     = "dev-group" # Changed default to avoid conflict with env_name if both are 'dev'
}

variable "apigee_namespace" {
  description = "The Kubernetes namespace for Apigee"
  type        = string
  default     = "apigee"
}

variable "apigee_version" {
  description = "The version of Apigee Hybrid to install"
  type        = string
  # e.g., default = "1.14.2-hotfix.1" - It's better to define this in one place, perhaps here.
}

variable "hostnames" {
  description = "The list of hostnames for the Apigee environment group"
  type        = list(string)
  # e.g., default = ["myapi.example.com"]
}

# System Node Pool Variables
variable "system_pool_node_count" {
  description = "The number of nodes for the system node pool."
  type        = number
  default     = 1
}


variable "runtime_pool_enable_autoscaling" {
  description = "Whether to enable autoscaling for the Apigee Runtime node pool."
  type        = bool
  default     = false
}

variable "runtime_pool_node_count" {
  description = "Node count in case autoscaling is false."
  type        = number
  default     = 2
}

# Apigee Runtime Node Pool Variables
variable "runtime_pool_min_count" {
  description = "Minimum number of nodes for the Apigee Runtime node pool."
  type        = number
  default     = 2
}

variable "runtime_pool_max_count" {
  description = "Maximum number of nodes for the Apigee Runtime node pool."
  type        = number
  default     = 2
}

variable "data_pool_enable_autoscaling" {
  description = "Whether to enable autoscaling for the Apigee Data node pool."
  type        = bool
  default     = false
}

variable "data_pool_node_count" {
  description = "Number of nodes for the Apigee Data node pool in case autoscale is false"
  type        = number
  default     = 1
}

# Apigee Data Node Pool Variables
variable "data_pool_min_count" {
  description = "Minimum number of nodes for the Apigee Data node pool."
  type        = number
  default     = 1
}

variable "data_pool_max_count" {
  description = "Maximum number of nodes for the Apigee Data node pool."
  type        = number
  default     = 1
}

#Add variable for svcAnnotations
variable "ingress_svc_annotations" {
  description = "Service Annotations for Apigee Services"
  type        = map(string)
  default     = {}
}