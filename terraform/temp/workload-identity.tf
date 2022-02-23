locals {
  config_map = {
    test1 = {
      gsa_name = "myapp-gsa"
      ksa_name = "myapp-ksa"
    }
  }
}

module "testpod-workload-identity" {
  for_each = local.config_map

  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${each.key}-workload-identity"
  project_id          = "maugram-dev"
  cluster_name        = "cluster-0223"
  location            = "us-central1-c"
  namespace           = "dev"
  gcp_sa_name         = each.value.gsa_name
  k8s_sa_name         = each.value.ksa_name
  use_existing_k8s_sa = true
  roles               = []
  #roles      = ["roles/cloudsql.client", "roles/autoscaling.metricsWriter", "roles/cloudtrace.agent", "roles/logging.logWriter", "roles/monitoring.metricWriter"]
}
