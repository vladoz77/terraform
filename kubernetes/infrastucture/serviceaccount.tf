resource "yandex_iam_service_account" "sa-k8s-admin" {
  name        = var.sa-name
  description = "k8s account admin"
}


resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-admin-permissions" {
  for_each = var.roles
  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-k8s-admin.id}"
}

resource "yandex_iam_service_account_key" "sa-k8s-admin-key" {
  service_account_id = yandex_iam_service_account.sa-k8s-admin.id
  description = "sa-k8s-admin-key file"
  key_algorithm      = "RSA_2048"
}
