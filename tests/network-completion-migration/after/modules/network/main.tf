module "network_completion" {
  source = "./modules/network-completion"
}

moved {
  from = terraform_data.igw_natgw_specific_route_tables
  to   = module.network_completion.module.igw_natgw_route_tables.terraform_data.custom
}

moved {
  from = terraform_data.sgw_specific_route_tables
  to   = module.network_completion.module.sgw_route_tables.terraform_data.custom
}

moved {
  from = terraform_data.lpg_specific_route_tables
  to   = module.network_completion.module.lpg_route_tables.terraform_data.custom
}

moved {
  from = terraform_data.drga_specific_route_tables
  to   = module.network_completion.module.drga_route_tables.terraform_data.custom
}

moved {
  from = terraform_data.non_gw_specific_remaining_route_tables
  to   = module.network_completion.module.remaining_route_tables.terraform_data.custom
}

moved {
  from = terraform_data.igw_natgw_specific_default_route_tables
  to   = module.network_completion.module.igw_natgw_route_tables.terraform_data.default
}

moved {
  from = terraform_data.sgw_specific_default_route_tables
  to   = module.network_completion.module.sgw_route_tables.terraform_data.default
}

moved {
  from = terraform_data.lpg_specific_default_route_tables
  to   = module.network_completion.module.lpg_route_tables.terraform_data.default
}

moved {
  from = terraform_data.drga_specific_default_route_tables
  to   = module.network_completion.module.drga_route_tables.terraform_data.default
}

moved {
  from = terraform_data.non_gw_specific_remaining_default_route_tables
  to   = module.network_completion.module.remaining_route_tables.terraform_data.default
}

moved {
  from = terraform_data.these
  to   = module.network_completion.terraform_data.these
}
