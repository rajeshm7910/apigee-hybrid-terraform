output "apigee_core_non_prod_sa_email" {
  description = "Email of the Apigee Non-Prod service account from the core module."
  value       = module.apigee_core.apigee_non_prod_sa_email
}

output "apigee_core_non_prod_sa_key_path" {
  description = "Path to the saved Apigee Non-Prod service account key file from the core module."
  value       = module.apigee_core.apigee_non_prod_sa_key_path
}

output "apigee_core_overrides_yaml_path" {
  description = "Path to the generated Apigee Hybrid overrides.yaml file from the core module."
  value       = module.apigee_core.apigee_overrides_yaml_path
}

output "apigee_core_service_yaml_path" {
  description = "Path to the generated Apigee Hybrid apigee-service.yaml file from the core module."
  value       = module.apigee_core.apigee_service_yaml_path
}

output "apigee_core_envgroup_private_key_file_path" {
  description = "Path to the self-signed private key file for the Apigee envgroup from the core module."
  value       = module.apigee_core.apigee_envgroup_private_key_file_path
}

output "apigee_core_envgroup_cert_file_path" {
  description = "Path to the self-signed certificate file for the Apigee envgroup from the core module."
  value       = module.apigee_core.apigee_envgroup_cert_file_path
}

output "apigee_core_setup_script_executed_trigger" {
  description = "Indicates if the Apigee setup script was triggered from the core module."
  value       = module.apigee_core.apigee_setup_script_executed_trigger
}

output "apigee_core_organization_id" {
  description = "The ID of the Apigee organization from the core module."
  value       = module.apigee_core.apigee_organization_id
}

output "apigee_core_environment_name" {
  description = "The name of the Apigee environment from the core module."
  value       = module.apigee_core.apigee_environment_name
}

output "apigee_core_envgroup_id" {
  description = "The ID of the Apigee environment group from the core module."
  value       = module.apigee_core.apigee_envgroup_id
}

# You can also have outputs specific to the apigee-on-aks module, like the kubeconfig path
output "aks_kubeconfig_path" {
  description = "Path to the generated kubeconfig file for the AKS cluster."
  value       = local_file.kubeconfig.filename
}

output "aks_cluster_name" {
  description = "Name of the deployed AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}