locals {
  availability_zones       = tolist(setunion(keys(var.args.master_nodes), keys(var.args.worker_nodes)))
  availability_zones_count = length(local.availability_zones)

  // Only 1 subnet is created per AZ (Availability Zone).
  // Map an AZ to id of the subnet created in that AZ.
  availability_zone_subnet_id_map = {
    for index, availability_zone in local.availability_zones : availability_zone => aws_subnet.private_subnets[index].id
  }

  master_nodes = flatten([
    for az, node_groups in var.args.master_nodes : [
      for node_group in node_groups : [
        for i in range(node_group.node_count) : [
          {
            az            = az,
            instance_type = node_group.instance_type
          }
        ]
      ]
    ]
  ])

  worker_nodes = flatten([
    for az, node_groups in var.args.worker_nodes : [
      for node_group in node_groups : [
        for i in range(node_group.node_count) : [
          {
            az            = az,
            instance_type = node_group.instance_type
          }
        ]
      ]
    ]
  ])
}
