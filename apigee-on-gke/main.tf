terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0" # Ensure compatibility with the Google provider
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate a random suffix for resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name_suffix = random_string.suffix.result
}

# Create VPC Network
resource "google_compute_network" "vpc" {
  name                    = "vpc-apigee-${local.name_suffix}"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-apigee-${local.name_suffix}"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Create Cloud Router
resource "google_compute_router" "router" {
  name    = "router-apigee-${local.name_suffix}"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Create Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "nat-apigee-${local.name_suffix}"
  router                            = google_compute_router.router.name
  region                            = google_compute_router.router.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create GKE Cluster
resource "google_container_cluster" "gke" {
  name     = "gke-apigee-${local.name_suffix}"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range"
    services_secondary_range_name = "service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"  # Consider restricting this in production
      display_name = "All"
    }
  }

  # Add network tags for NAT
  network_policy {
    enabled = true
  }

  # Add network tags for NAT
  node_config {
    tags = ["nat-route"]
  }
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  # Optional: You can filter zones if needed, e.g., by status
  # status = "UP"
}


# Create Node Pool for Runtime
resource "google_container_node_pool" "runtime" {
  name       = "apigeerun"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"

    labels = {
      "apigee-runtime" = "true"
    }

    tags = ["apigee-runtime", "nat-route"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Create Node Pool for Data
resource "google_container_node_pool" "data" {
  name       = "apigeedata"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 1
  # Specify the zone for the node pool, using the first available zone

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"

    labels = {
      "apigee-data" = "true"
    }

    tags = ["apigee-data", "nat-route"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Generate kubeconfig
resource "local_file" "kubeconfig" {
  content  = <<-KUBECONFIG
    apiVersion: v1
    kind: Config
    current-context: ${google_container_cluster.gke.name}
    contexts:
    - context:
        cluster: ${google_container_cluster.gke.name}
        user: ${google_container_cluster.gke.name}
      name: ${google_container_cluster.gke.name}
    clusters:
    - cluster:
        certificate-authority-data: ${base64encode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)}
        server: https://${google_container_cluster.gke.endpoint}
      name: ${google_container_cluster.gke.name}
    users:
    - name: ${google_container_cluster.gke.name}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: gcloud
          args:
          - container
          - clusters
          - get-credentials
          - ${google_container_cluster.gke.name}
          - --region=${var.region}
          - --project=${var.project_id}
  KUBECONFIG
  filename = "${path.module}/kubeconfig"
}

resource "null_resource" "cluster_setup" {
  # Use local-exec provisioner to run a script to configure kubectl
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region ${var.region} --project ${var.project_id}"
  }
  depends_on = [
    local_file.kubeconfig,
    google_container_cluster.gke,
  ]
}


# Use the apigee-hybrid-core module
module "apigee_hybrid" {
  source = "../apigee-hybrid-core"

  project_id                = var.project_id
  region                    = var.region
  apigee_org_name          = var.apigee_org_name
  apigee_env_name          = var.apigee_env_name
  apigee_envgroup_name     = var.apigee_envgroup_name
  apigee_namespace         = var.apigee_namespace
  apigee_version           = var.apigee_version
  cluster_name             = google_container_cluster.gke.name
  create_org               = var.create_org
  apigee_org_display_name  = var.apigee_org_display_name
  apigee_env_display_name  = var.apigee_env_display_name
  apigee_instance_name     = var.apigee_instance_name
  apigee_envgroup_hostnames = var.hostnames
  apigee_cassandra_replica_count = var.apigee_cassandra_replica_count
  ingress_name             = var.ingress_name
  ingress_svc_annotations  = var.ingress_svc_annotations
  overrides_template_path = "${path.module}/../apigee-hybrid-core/overrides-templates.yaml" # Example if you want to be explicit
  service_template_path   = "${path.module}/../apigee-hybrid-core/apigee-service-template.yaml" # Example
  apigee_install          = var.apigee_install
  billing_type            = var.billing_type

  depends_on = [
    google_container_cluster.gke,
    google_container_node_pool.runtime,
    google_container_node_pool.data,
    null_resource.cluster_setup,
  ]
} 