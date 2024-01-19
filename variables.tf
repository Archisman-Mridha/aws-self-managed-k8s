variable "args" {
  type = object({
    project_name = string
    region       = string

    credentials = object({
      access_key = string
      secret_key = string
    })

    cluster_name = string
    vpc_cidr     = string

    master_nodes = map(list(object({
      instance_type = string
      node_count    = number
    })))

    worker_nodes = map(list(object({
      instance_type = string
      node_count    = number
    })))
  })
}
