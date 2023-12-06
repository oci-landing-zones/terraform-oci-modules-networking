# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

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