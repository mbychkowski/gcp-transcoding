# Copyright 2023 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "repo-batch-jobs"
  description   = "Batch jobs Artifact Registry."
  format        = "DOCKER"
}

# Cloud Deploy | Pipeline
resource "google_clouddeploy_delivery_pipeline" "primary" {
  location    = var.region
  name        = "ffmpeg-api-cd"
  description = "Delivery pipeline for FFMPEG API (in Python)."
  project     = local.project.id

  serial_pipeline {
    stages {
      profiles  = ["profile-dev"]
      target_id = "target-primary-gke"
    }

    stages {
      profiles  = ["profile-staging"]
      target_id = "target-primary-gke"
    }

    stages {
      profiles  = ["profile-prod"]
      target_id = "target-primary-gke"
    }
  }

  annotations = {}

  labels = {
    lang = "python"
  }
}

# Cloud Deploy | Targets
resource "google_clouddeploy_target" "primary" {
  project     = local.project.id
  location    = var.region
  name        = "target-primary-gke"
  description = "Primary cluster (internal, autopush, integration tests, staging, production)"

  gke {
    cluster = module.gke.name
  }

  require_approval = true

  labels = {
    runtime = "gke"
  }
}