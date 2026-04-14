module "rbac" {
  source = "github.com/mlinxfeld/terraform-az-fk-rbac"

  scope                = module.storage.storage_account_id
  principal_id         = module.spoke2_vm.vm_principal_id
  role_definition_name = "Storage Blob Data Contributor"
}
