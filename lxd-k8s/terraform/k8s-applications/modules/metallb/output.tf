output "ippools" {
  value = [for key, val in var.ippools : {
    name = key
    addresses = val
  }]
}