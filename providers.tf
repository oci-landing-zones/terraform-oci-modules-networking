# ####################################################################################################### #
# Copyright (c) 2023 Oracle and/or its affiliates,  All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl. #
# Author: Cosmin Tudor                                                                                    #
# Author email: cosmin.tudor@oracle.com                                                                   #
# Last Modified: Wed Nov 15 2023                                                                          #
# Modified by: Cosmin Tudor, email: cosmin.tudor@oracle.com                                               #
# ####################################################################################################### #


terraform {
  required_version = ">= 1.2.0, < 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "<= 5.16.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
