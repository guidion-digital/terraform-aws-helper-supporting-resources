locals {
  sqs_queues = {
    for this_queue, these_values in var.sqs_queues :
    var.namespacing_enabled ? "${var.application_name}-${this_queue}" : this_queue => these_values
  }
}

module "sqs_queues" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  for_each = local.sqs_queues

  name = each.key

  # Options
  content_based_deduplication     = each.value.content_based_deduplication
  deduplication_scope             = each.value.deduplication_scope
  delay_seconds                   = each.value.delay_seconds
  dlq_content_based_deduplication = each.value.dlq_content_based_deduplication
  dlq_deduplication_scope         = each.value.dlq_deduplication_scope
  dlq_delay_seconds               = each.value.dlq_delay_seconds
  dlq_message_retention_seconds   = each.value.dlq_message_retention_seconds
  dlq_receive_wait_time_seconds   = each.value.dlq_receive_wait_time_seconds
  dlq_visibility_timeout_seconds  = each.value.dlq_visibility_timeout_seconds
  fifo_queue                      = each.value.fifo_queue
  fifo_throughput_limit           = each.value.fifo_throughput_limit
  max_message_size                = each.value.max_message_size
  message_retention_seconds       = each.value.message_retention_seconds
  receive_wait_time_seconds       = each.value.receive_wait_time_seconds
  visibility_timeout_seconds      = each.value.visibility_timeout_seconds

  create_queue_policy = length(each.value.readwrite_arns) == 0 && length(each.value.read_arns) == 0 ? false : true
  queue_policy_statements = {
    self = {
      "Sid" : "self",
      "Version" : "2012-10-17",
      "Id" : "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.application_name}-${each.key}/SQSDefaultPolicy"
    },
    read_write = {
      sid = "ReadWrite"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:StartMessageMoveTask"
      ]
      resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.key}"]
      principals = [for this_arn in each.value.readwrite_arns : {
        type        = "AWS"
        identifiers = [this_arn]
      }]
    }
    read = {
      sid = "Read"
      actions = [
        "sqs:ReceiveMessage"
      ]
      resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.key}"]
      principals = [for this_arn in each.value.read_arns : {
        type        = "AWS"
        identifiers = [this_arn]
      }]
    }
  }

  # Dead letter queue
  create_dlq              = true
  redrive_policy          = each.value.redrive_policy
  create_dlq_queue_policy = length(each.value.readwrite_arns) == 0 && length(each.value.read_arns) == 0 ? false : true
  dlq_queue_policy_statements = {
    self = {
      "Sid" : "self",
      "Version" : "2012-10-17",
      "Id" : "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.key}/SQSDefaultPolicy"
    },

    read_write = {
      sid = "ReadWrite"
      actions = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
      ]
      resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.key}"]
      principals = [for this_arn in each.value.readwrite_arns : {
        type        = "AWS"
        identifiers = [this_arn]
      }]
    }

    read = {
      sid = "Read"
      actions = [
        "sqs:ReceiveMessage"
      ]
      resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.key}"]
      principals = [for this_arn in each.value.read_arns : {
        type        = "AWS"
        identifiers = [this_arn]
      }]
    }
  }

  tags = var.tags
}
