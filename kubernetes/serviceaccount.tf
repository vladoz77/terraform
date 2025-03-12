resource "yandex_iam_service_account" "sa-k8s-admin" {
  name        = var.sa-name
  description = "k8s account admin"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-admin-permissions" {
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-k8s-admin.id}"
}