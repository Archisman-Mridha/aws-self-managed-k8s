variable "args" {
  type = object({

    credentials = object({
      access_key = string
      secret_key = string
    })

    ami_id = string
  })
}
