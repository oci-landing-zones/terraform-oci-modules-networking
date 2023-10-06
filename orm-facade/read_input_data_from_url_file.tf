data "http" "input_config_file_url" {

  url = var.input_config_file_url

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  json_config_file = data.http.input_config_file_url != null ? try(jsondecode(data.http.input_config_file_url.body), null) : null

  yaml_config_file = data.http.input_config_file_url != null ? try(yamldecode(data.http.input_config_file_url.body), null) : null

  config_file = coalesce(local.json_config_file, local.yaml_config_file, null)

  network_configuration_from_input_json_yaml_file = local.config_file != null ? contains(keys(local.config_file), "network_configuration") ? local.config_file.network_configuration : null : null
}