module "test_waf" {
  source            = "../"
  waf_configuration = var.waf_configuration
}