# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #

output "provisioned_l7_load_balancers" {
  description = "Provisioned l7_load_balancers"
  value = {
    l7_load_balancers      = local.provisioned_l7_lbs
    l7_lb_backend_sets     = local.provisioned_l7_lbs_backend_sets
    l7_lb_back_ends        = local.provisioned_l7_lb_backends
    l7_lb_cipher_suites    = local.provisioned_l7_lbs_cipher_suites
    l7_lb_path_route_sets  = local.provisioned_l7_lbs_path_route_sets
    l7_lb_hostnames        = local.provisioned_l7_lbs_hostnames
    l7_lb_routing_policies = local.provisioned_l7_lbs_path_routing_policies
    l7_lb_rule_sets        = local.provisioned_l7_lbs_path_rule_sets
    l7_lb_certificates     = local.provisioned_l7_lbs_certificates
    l7_lb_listeners        = local.provisioned_l7_lb_listeners
  }
}