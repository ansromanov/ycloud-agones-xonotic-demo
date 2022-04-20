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

locals {
  cluster_ipv4_range = "10.96.0.0/16"
  service_ipv4_range = "10.112.0.0/16"
}

resource "yandex_vpc_security_group" "vpc_default" {
  name        = "${var.project_name}-vpc-default-sg"
  description = "Default VPC security group"
  network_id  = yandex_vpc_network.this.id

  labels = var.labels

  ingress {
    protocol       = "TCP"
    description    = "Allow Whitelisted subnets"
    v4_cidr_blocks = var.whitelist_subnets
    port           = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "Allow all traffic between cluster and nodes"
    port              = -1
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow LB"
    port           = -1
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow POD and Service networks"
    port           = -1
    v4_cidr_blocks = [local.cluster_ipv4_range, local.service_ipv4_range]
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow diagnostics"
    port           = -1
    v4_cidr_blocks = concat(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"], var.whitelist_subnets)
  }

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
    port           = -1
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

resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster" {
  folder_id = var.folder_id

  role   = "editor"
  member = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node" {
  folder_id = var.folder_id

  role   = "editor"
  member = "serviceAccount:${yandex_iam_service_account.k8s_node.id}"
}

resource "yandex_kms_symmetric_key" "this" {
  name              = "${var.project_name}-symetric-key"
  description       = "description for key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}

locals {
  cluster_version = "1.21"
}

resource "yandex_kubernetes_cluster" "cluster" {
  name        = "${var.project_name}-k8s-cluster"
  description = "Zonal K8S cluster for ${var.project_name} project"

  network_id = yandex_vpc_network.this.id

  master {
    version = local.cluster_version
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

  cluster_ipv4_range = local.cluster_ipv4_range
  service_ipv4_range = local.service_ipv4_range

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

resource "yandex_kubernetes_node_group" "default" {
  cluster_id  = yandex_kubernetes_cluster.cluster.id
  name        = "${var.project_name}-k8s-cluster-default-ng"
  description = "Default cluster node group"
  version     = local.cluster_version

  labels = var.labels

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      ipv4               = true
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.this.id}"]
      security_group_ids = ["${yandex_vpc_security_group.vpc_default.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = var.default_zone
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
  }
}
