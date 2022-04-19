# flyaway-testapp
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

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->