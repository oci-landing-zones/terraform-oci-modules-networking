<!-- BEGIN_TF_DOCS -->
# Simple OCI Native Application(L7) Load Balancer provisioned on an existing VCN/subnet 

## Description

This is an example for a simple/basic provisioning of a OCI Native L7 Load Balancer on an existing VCN/subnet.

For detailed description of the ```l7_load_balancers_configuration``` OCI Native L7 Load Balancer core module please refer to the core module specific [README.md](../../README.md) and [SPEC.md](../../SPEC.md).

This example is leveraging the fully dynamic characteristics of the complex OCI Native L7 Load Balancer module input to describe the following networking topology:

- OCI Application L7 LBaaS construct provisioned
- no VCN created
- under the ```l7_load_balancers``` we're going to create a single OCI Native Application LBaaS that will contain:
    - one ```backend set``` with 2 ```backends```
    - one ```cipher suite```
    - one ```path route set```
    - two ```host names```
    - one ```routing policy```
    - one ```rule set```
    - one ```certificate```
    - two ```listeners```

- It is also creating a ```public_ip``` reservation and attaching it to the ```load balancer```.

__NOTE 1:__ Please note that the entire configuration is a single complex input parameter and you're able to edit it and change the resources names and any of their configuration and, also, you're able to change the input configuration topology/structure.

## Diagram of the provisioned networking topology

![](diagrams/public-lb.png)

## Instantiation

For clarity and proper separation and isolation we've separated the input parameters into 2 files by leveraging terraform ```*.auto.tfvars``` feature:

- [terraform.tfvars](./terraform.tfvars.template)


- [lbaas_configuration.auto.tfvars](./lbaas_configuration.auto.tfvars)


## Output Example:

```

```