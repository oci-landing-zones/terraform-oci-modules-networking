# August 28, 2024 Release Notes - 0.6.9

## Updates
1. All modules now require Terraform binary equal or greater than 1.3.0.
2. *cislz-terraform-module* tag renamed to *ocilz-terraform-module*.


# July 24, 2024 Release Notes - 0.6.8

## New
1. [VTAP module](./modules/vtap/)
    - New VTAP (Virtual Test Access Point) module available.
## Updates
1. Aligned [README.md](./README.md) structure to Oracle's GitHub organizations requirements.


# May 15, 2024 Release Notes - 0.6.7

## New
1. Support added for private DNS with the introduction of *dns_resolver* attribute for VCNs.
2. New modules for [WAF (Web Application Firewall)](./modules/waf/) and [WAA (Web Application Acceleration)](./modules/waa/).
2. Examples of network topologies for OKE deployments added. See [oke-examples](./examples/oke-examples/).


# April 16, 2024 Release Notes - 0.6.6

## Updates
1. Module now supports external dependencies on private IP addresses, DRG attachments, remote peering connections and local peering gateways. See [External Dependencies](./README.md#ext-dep) for details.
2. All dependency variables are now strongly typed, enhancing usage guidance.


# April 08, 2024 Release Notes - 0.6.5
## Additions
1. MVP module for Network Load Balancers.

## Updates
1. Module dependency on externally managed network resources enhanced, including improved examples and documentation.
2. Release tracking via freeform tags.

## Fixes
1. L7 load balancers module dependency on compartments.
2. IPV6 CIDR block data type changed from bool to string in L7 load balancers module.


# March 21, 2023 Release Notes - 0.1.0
## Added
1. [Initial Release](#0-1-0-initial)
### <a name="0-1-0-initial">Initial Release</a>
Module for networking.