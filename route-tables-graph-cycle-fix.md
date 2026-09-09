# Route Tables TF Dependency Graph Cycles - Description of the algorithm addressing the cycles

## 1. Problem Description

  - When creating all defined route tables under a single ```"oci_core_route_table" ```resource, practically we'll get one single node in the TF graph - let's name this ```RTS-Node```.
  - Route Tables can be referenced by the following elements: ``IGW``, ``NAT-GW``, ``SGW``, ``DRG-ATTACHMENT``, ``LPG`` and ``SUBNET``. We'll be creating those under different resources getting 6 different nodes in the graph named as follows:
    ```IGWS-Node```, ```NATGWS-Node```, ```SGWS-Node```, ```DRGAS-Node```, ``LPGS-Node``, ```SUBNETS-Node```
  - But the route table route rules have the option to target resources that are also part of the graph, such as ``IGW``, ``NAT-GW``, ``SGW``, ``DRG``, ``LPG`` and private IPs, ***creating the possibility for cycles in the graph***.
  - Terraform first builds the graph and with all the potential options - calling that ```POTENTIAL GRAPH```.
  - After ```POTENTIAL GRAPH``` is built, the actual desired configuration is evaluated.
  - ```POTENTIAL GRAPH``` is checked for cycles. Cycles are not supported in the ```POTENTIAL GRAPH``` and they are errored out at terraform plan - as ***cycle graph errors***.
  - One route table can be attached to multiple elements - the solution should not duplicate route tables.

  ![RouteTables-TF-GraphCycle-Issue](./images/RouteTables-TF-GraphCycle-Issue.png)

## 2. Solution

  - In the same way as terraform graph do not support cycles, in networking, cycles or loops are not supported as well - and if one tries to configure those in OCI, OCI will catch and report them as errors.
  - To solve our problem described above, we need to structure the Terraform resources so the dependency graph has no cycles before OCI validates the final routing configuration.
  - The main impact of implementing those checks will be:
       - we'll split the single ```RTS-Node``` into different nodes(5) and each of those nodes will NOT be in a cycle graph relation(referencing one another) with any of the 6 RT attachable entities nodes:
         ```IGWS-Node```, ```NATGWS-Node```, ```SGWS-Node```, ```DRGAS-Node```, ```LPGS-Node```, ```SUBNETS-Node```
       - The split criteria follow the OCI component relationships used by the module and keep attachable resources from depending on route table nodes that can depend back on them.

  ![RouteTables-TF-GraphCycle-Solution](./images/RouteTables-CycleGraph-Fix-Algorithm.png)

### 2.1. Describing the RTS-Node splitting in 5 nodes:

- RT-NODE-1-IGW-NATGW-Atachable-RTs:
    - This will contain all the RTs that are attachable to IGWs or NATGWs
    - The route rules of these route tables will only be able to target: private_ips, OCIDs(outside private IPs), null/unresolved targets or no route rules in the route table.
- RT-NODE-2-SGW-Atachable-RTs:
    - This will contain not *all but specific RTs that are attachable to SGWs - specific SGWs route tables
    - The route rules of these route tables will only be able to target:
        - just DRGS
          - OR
        - DRGS AND any of the available targets for NODE 1 - IGW-NATGW-Atachable-RTs
- RT-NODE-3-LPG-Atachable-RTs:
    - This will contain not *all but specific RTs that are attachable to LPGs - specific LPGs route tables
    - The route rules of these route tables will only be able to target:
        - just SGWS
            - OR
        - SGWS AND any of the available targets for NODE 1 - IGW-NATGW-Atachable-RTs
- RT-NODE-4-DRGA-Atachable-RTs:
    - This will contain not all* but specific RTs that are attachable to DRG attachments - specific DRG attachment route tables
    - The route rules of these route tables will only be able to target:
        - just LPGS
            - OR
        - LPGS AND any of the available targets for NODE 3 - LPG-Atachable-RTs, as implemented by the module
- RT-NODE-5-REMAINING-RTS: The remaining RTs that do not fit into the criteria for NODES 1-4.
    - These will only be attachable to SUBNETS

### 2.2. Describing the relation in between 6 RT attachable entities nodes and the 5 RTS-Node splitted nodes:

-  6 RT attachable entities nodes
    - AT-NODE-1-IGWS and AT-NODE-1-NATGW
        - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs route tables or the VCN default route table
        - can be referred by: RT-NODE-5-REMAINING-RTS route rules
    - AT-NODE-2-SGW:
        - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs and RT-NODE-2-SGW-Atachable-RTs route tables or the VCN default route table
        - can be referred by: RT-NODE-3-LPG-Atachable-RTs and RT-NODE-4-DRGA-Atachable-RTs route rules
    - AT-NODE-3-LPG:
        - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs and RT-NODE-3-LPG-Atachable-RTs route tables or the VCN default route table
        - can be referred by:  RT-NODE-4-DRGA-Atachable-RTs route rules
    - AT-NODE-4-DRGA:
        - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs, RT-NODE-3-LPG-Atachable-RTs and RT-NODE-4-DRGA-Atachable-RTs route tables or the VCN default route table
        - can be referred by:  NONE. Route rules target DRGs, not DRG attachments.
    - AT-NODE-5-SUBNET:
        - can refer: RT-NODE-1-IGW-NATGW-Atachable-RTs, RT-NODE-3-LPG-Atachable-RTs, RT-NODE-2-SGW-Atachable-RTs, RT-NODE-5-REMAINING-RTS and RT-NODE-4-DRGA-Atachable-RTs route tables
        - can be referred by:  NONE

- Notice that there is no loop/cycle in between the nodes described above.

## 3. Limitations

### 3.1. Changing Route Table Node
Once a route table update will generate a switch from one RT-NODE to another one, and the initial node is referenced by an AT-NODE, this will generate an error as terraform will
attempt to delete the RT from the current node and recreate it as part of a different node without updating the AT-NODE(referencing node).
  - The workaround will be to 1st delete manually the reference from the *tfvars/json/yaml configuration, run terraform apply and then update and apply the RT with an update that will generate
a move from one RT-NODE to another one.
  - This limitation will also, as said, generate a recreation of the object and not just an update of the RT object.

### 3.2. Route Tables targeting Private IPs

Route rules can reference a private IP by setting `network_entity_id` to either a
literal private IP OCID or a key present in `private_ips_dependency`. The target key is
known from configuration even when its OCID remains unknown until apply.

Subnets are initially created with their VCN default route table. After the private IP
target and configured route table are available, `oci_core_route_table_attachment`
applies the final subnet association. This separates subnet creation from route-rule
target creation and allows both to be managed in one Terraform graph.

`network_entity_key` remains available for backward compatibility but is deprecated.
Use `network_entity_id`; `network_entity_key` will be removed in the next major release.

### 3.3. Route Table Partitions

Route tables are assigned to five partitions according to the types of resources they
reference and the resources to which they can be attached. Each partition is an
instance of the shared `modules/network-completion/modules/route-table-partition` child
module. Separate inputs and outputs keep gateway dependencies isolated while the shared
implementation avoids duplicating the custom and default route-table resource
definitions.

## 4. Default Route Tables

### 4.1. Default route tables use the same split

The above functionality is also implemented for customized default VCN route tables.
