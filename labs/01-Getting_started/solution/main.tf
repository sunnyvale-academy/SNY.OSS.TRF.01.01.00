// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("/home/vagrant/SNY-OSS-TRF-01-01-00-870577b1e676.json")}"
 project     = "sny-oss-trf-01-01-00"
 region      = "europe-west4"
}

