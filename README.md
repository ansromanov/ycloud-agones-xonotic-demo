# flyaway-testapp

How to apply code:
1. Install YC CLI curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
2. Install Terraform
3. Create `terraform.tfvars` file with following content:
    ```terraform
    token        = <Yandex.Cloud token>
    cloud_id     = <Yandex.Cloud cloud id>
    project_name = "flyaway-xonotic"
    folder_id    = <Yandex.Cloud folder id>
    labels = {
      "owner"   = <something like your email>
      "project" = "flyaway-xonotic"
      "env"     = "dev"
    }
    default_zone = "ru-central1-a"
    ```
1. Deploy k8s cluster with `terraform apply`
1. Get cluster credentials
  ```sh
  yc managed-kubernetes cluster get-credentials flyaway-xonotic-k8s-cluster --external
  ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | 0.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| yandex_iam_service_account.k8s_cluster | resource |
| yandex_iam_service_account.k8s_node | resource |
| yandex_kms_symmetric_key.this | resource |
| yandex_kubernetes_cluster.cluster | resource |
| yandex_kubernetes_node_group.default | resource |
| yandex_resourcemanager_folder_iam_member.k8s_cluster | resource |
| yandex_resourcemanager_folder_iam_member.k8s_node | resource |
| yandex_vpc_network.this | resource |
| yandex_vpc_security_group.vpc_default | resource |
| yandex_vpc_subnet.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | Token | `string` | n/a | yes |
| <a name="input_default_zone"></a> [default\_zone](#input\_default\_zone) | Default zone | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Folder ID | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels | `map(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | Token | `string` | n/a | yes |
| <a name="input_whitelist_subnets"></a> [whitelist\_subnets](#input\_whitelist\_subnets) | Whitelisted subnets to access cluster. Use 0.0.0.0/0 to publicly access from anywhere | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->