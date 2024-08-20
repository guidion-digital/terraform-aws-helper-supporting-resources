variable "tags" {
  description = "Tags to apply to all resources"
  default     = {}
}

variable "application_name" {
  description = "What is the application name these resources are for?"
}

variable "namespacing_enabled" {
  description = "Whether to prepend var.application_name to supporting resources like var.dynamodb_tables"
  type        = bool
  default     = true
}

variable "dynamodb_tables" {
  description = "DynamoDB tables will be created if values are supplied for this"

  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html
  # https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table
  type = map(object({
    attributes                            = list(map(string)),
    hash_key                              = string,
    range_key                             = optional(string),
    billing_mode                          = optional(string, "PROVISIONED"),
    read_capacity                         = optional(number, 5),
    write_capacity                        = optional(number, 5),
    autoscaling_enabled                   = optional(bool, true),
    ignore_changes_global_secondary_index = optional(bool, false),
    ttl_attribute_name                    = optional(string, ""),
    stream_view_type                      = optional(string, "NEW_IMAGE"),
    point_in_time_recovery_enabled        = optional(bool, false),
    timeouts                              = optional(map(string), { "create" : "10m", "delete" : "10m", "update" : "60m" }),

    autoscaling_read_scale_in_cooldown  = optional(number, 50),
    autoscaling_read_scale_out_cooldown = optional(number, 40),
    autoscaling_read_target_value       = optional(number, 45),
    autoscaling_read_max_capacity       = optional(number, 10),

    autoscaling_write_scale_in_cooldown  = optional(number, 50),
    autoscaling_write_scale_out_cooldown = optional(number, 40),
    autoscaling_write_target_value       = optional(number, 45),
    autoscaling_write_max_capacity       = optional(number, 10),

    global_secondary_indexes : optional(list(
      object({
        name               = string,
        hash_key           = string,
        range_key          = string,
        projection_type    = optional(string, "INCLUDE"),
        non_key_attributes = list(string),
        write_capacity     = optional(number, 10)
        read_capacity      = optional(number, 10)

        autoscaling = optional(object({
          read_max_capacity  = optional(number, 30),
          read_min_capacity  = optional(number, 10),
          write_max_capacity = optional(number, 30),
          write_min_capacity = optional(number, 10)
        }), null)
      })),
    [])
  }))

  default = {}
}

variable "sqs_queues" {
  description = "SQS queues will be created if values are supplied for this"

  # https://github.com/terraform-aws-modules/terraform-aws-sqs
  type = map(object({
    content_based_deduplication     = optional(bool, null),
    deduplication_scope             = optional(string, null),
    delay_seconds                   = optional(number, null),
    dlq_content_based_deduplication = optional(bool, null),
    dlq_deduplication_scope         = optional(string, null),
    dlq_delay_seconds               = optional(number, null),
    dlq_message_retention_seconds   = optional(number, null),
    dlq_receive_wait_time_seconds   = optional(number, null),
    dlq_visibility_timeout_seconds  = optional(number, null),
    fifo_queue                      = optional(bool, false),
    fifo_throughput_limit           = optional(string, null),
    max_message_size                = optional(number, null),
    message_retention_seconds       = optional(number, null),
    receive_wait_time_seconds       = optional(number, null),
    visibility_timeout_seconds      = optional(number, null),
    readwrite_arns                  = optional(list(string), []),
    read_arns                       = optional(list(string), []),
    redrive_policy = optional(object({
      maxReceiveCount = optional(number, 10)
      }), {
      maxReceiveCount = 10
    })
  }))

  default = {}
}

