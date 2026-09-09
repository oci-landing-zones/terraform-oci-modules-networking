# Network Completion

This internal module owns the five custom route-table partitions, the five customized
default-route-table partitions, and the final subnet route-table attachments used by
the networking root module. The five partitions are static module calls to one shared
worker, so the custom and default route-table resource bodies are maintained once.

The root module supplies each partition and target type separately. This is deliberate:
Terraform builds dependency edges from references even when they appear in locals,
`try`, conditionals, or null guards. Combining route targets or route-table outputs at
the module boundary can recreate the gateway dependency cycle. The worker calls remain
static because wrapping them in one `for_each` module call would combine their graph
dependencies.

Subnets are created by the root module without `route_table_id`, so OCI initially uses
the VCN default route table. This module creates the desired route tables after their
targets exist and then makes the attachment the sole owner of the final association.
Do not add `create_before_destroy` to the attachment.

This module is an implementation detail. Existing callers should continue invoking the
networking root module and consuming its public outputs.
