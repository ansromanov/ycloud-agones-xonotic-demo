resource "yandex_vpc_network" "this" {
  name      = "${var.project_name}-vpc"
  folder_id = var.folder_id
  labels    = var.labels
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.project_name}-zone"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.this.id
}

resource "yandex_vpc_security_group" "vpc_default" {
  name        = "${var.project_name}-vpc-default-sg"
  description = "Default VPC security group"
  network_id  = yandex_vpc_network.this.id

  labels = var.labels

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTPs inside VPC"
    v4_cidr_blocks = ["10.0.2.0/24"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outside traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = -1
    to_port        = -1
  }
}

resource "yandex_iam_service_account" "k8s_cluster" {
  name        = "${var.project_name}-k8s-cluster"
  description = "service account to manage K8s cluster"
}

resource "yandex_iam_service_account" "k8s_node" {
  name        = "${var.project_name}-k8s-node"
  description = "service account to manage K8s nodes"
}

resource "yandex_kms_symmetric_key" "this" {
  name              = "${var.project_name}-symetric-key"
  description       = "description for key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}

resource "yandex_kubernetes_cluster" "cluster" {
  name        = "${var.project_name}-k8s-cluster"
  description = "Zonal K8S cluster for ${var.project_name} project"

  network_id = yandex_vpc_network.this.id

  master {
    version = "1.21"
    zonal {
      zone      = yandex_vpc_subnet.this.zone
      subnet_id = yandex_vpc_subnet.this.id
    }

    public_ip = true

    security_group_ids = ["${yandex_vpc_security_group.vpc_default.id}"]

    maintenance_policy {
      auto_upgrade = false

    }
  }

  cluster_ipv4_range = "172.16.0.0/16"
  service_ipv4_range = "172.17.0.0/16"

  service_account_id      = yandex_iam_service_account.k8s_cluster.id
  node_service_account_id = yandex_iam_service_account.k8s_node.id

  labels = var.labels

  release_channel         = "REGULAR"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.this.id
  }

  depends_on = [
    yandex_iam_service_account.k8s_cluster,
    yandex_iam_service_account.k8s_node
  ]
}
