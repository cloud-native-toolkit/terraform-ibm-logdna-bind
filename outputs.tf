output "sync" {
  value = "logdna"
  depends_on = [null_resource.logdna_bind]
}
