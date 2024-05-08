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