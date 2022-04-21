provider "google" {
  project = "maugram-dev"
  region  = "us-central1"
}

provider "google" {
  alias = "stg"

  project = "maugram-stg"
  region  = "us-central1"
}

