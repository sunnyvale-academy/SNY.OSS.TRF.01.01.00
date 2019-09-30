credentials    = "/home/vagrant/SNY-OSS-TRF-01-01-00-870577b1e676.json"
project_id         = "sny-oss-trf-01-01-00"
region             = "europe-west4"
zones              = ["europe-west4-a", "europe-west4-b", "europe-west4-c"]
name               = "gke-cluster"
machine_type       = "g1-small"
min_count          = 1
max_count          = 3
disk_size_gb       = 10
service_account    = "terraform@sny-oss-trf-01-01-00.iam.gserviceaccount.com"
initial_node_count = 2

