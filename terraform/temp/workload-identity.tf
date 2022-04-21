locals {
  config_map = {
    test1 = {
      gsa_name        = "myapp-gsa"
      ksa_name        = "myapp-ksa"
      namespace       = "dev"
      annotate_k8s_sa = false
      #annotate_k8s_sa = true
    },
    #test2 = {
    #  gsa_name = "myapp2-gsa"
    #  ksa_name = "myapp2-ksa"
    #  namespace = "dev2"
    #  annotate_k8s_sa = false
    #}
  }
}

module "workload-identity-test" {
  for_each = local.config_map

  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "v19.0.0"
  name                = "${each.key}-workload-identity"
  project_id          = "maugram-dev"
  cluster_name        = "cluster-0315"
  location            = "us-central1-c"
  namespace           = each.value.namespace
  gcp_sa_name         = each.value.gsa_name
  k8s_sa_name         = each.value.ksa_name
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  roles               = ["roles/cloudsql.client", "roles/storage.admin"]
}


resource "google_service_account" "test2_cluster_service_account" {
  account_id = "myapp2-gsa"
  display_name = "GCP SA bound to K8S SA myapp2-ksa"
}

resource "google_service_account_iam_member" "test2_iam_member" {
  service_account_id = google_service_account.test2_cluster_service_account.id
  member = "serviceAccount:maugram-dev.svc.id.goog[dev2/myapp2-ksa]"
  role   = "roles/iam.workloadIdentityUser"
}

resource "google_project_iam_member" "test2_workload_identity_sa_bindings" {
  member  = "serviceAccount:myapp2-gsa@maugram-dev.iam.gserviceaccount.com"
  role    = "roles/cloudsql.client"
  project = "maugram-dev"
}

module "workload-identity-test3" {
  source = "./modules/workload-identity"

  project       = "maugram-dev"
  gcp_sa_name   = "myapp3-gsa"
  k8s_sa_name   = "myapp3-ksa"
  k8s_namespace = "dev"
  roles         = ["roles/cloudsql.client", "roles/storage.admin"]
}

# カスタムロールテスト
resource "google_service_account" "custom_role_sa_test" {
  account_id   = "custome-role-sa"
  display_name = "custom role test"
  project      = "maugram-dev"
}
resource "google_project_iam_custom_role" "custom_role_test" {
  role_id     = "myCustomRole"
  title       = "My Custom Role"
  description = "A description"
  permissions = [
    "cloudsql.instances.connect",
    "cloudsql.instances.get",
    "datastore.entities.create",
    "datastore.entities.delete",
    "datastore.entities.get",
    "datastore.entities.list",
    "datastore.entities.update",
    "firebaseauth.users.delete",
    "firebaseauth.users.get",
    "firebaseauth.users.sendEmail",
    "firebaseauth.users.update",
  ]
}
resource "google_project_iam_member" "custome_role_binding" {
  project = "maugram-dev"
  role    = google_project_iam_custom_role.custom_role_test.id
  member  = "serviceAccount:${google_service_account.custom_role_sa_test.email}"
}


# 別GCPプロジェクトのWorkload Identityテスト
resource "google_service_account_iam_member" "workload_identity_iam_member_accross_prj" {
  #service_account_id = "projects/maugram-stg/serviceAccounts/gcs-accessor@maugram-stg.iam.gserviceaccount.com"
  service_account_id = "projects/maugram-dev/serviceAccounts/myapp2-gsa@maugram-dev.iam.gserviceaccount.com"
  member             = "serviceAccount:maugram-dev.svc.id.goog[dev/myapp-ksa2]"
  role               = "roles/iam.workloadIdentityUser"
}
resource "google_project_iam_member" "cross_prj_iam" {
  for_each = toset(["roles/storage.admin", "roles/cloudsql.client"])
  provider = google.stg
  project  = "maugram-stg"
  role     = each.value
  member   = "serviceAccount:myapp2-gsa@maugram-dev.iam.gserviceaccount.com"
}
