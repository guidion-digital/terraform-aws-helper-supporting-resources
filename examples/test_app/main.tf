module "supporting_resources" {
  source = "../../"

  application_name = "app-x"

  dynamodb_tables = {
    "table-x" = {
      name                        = "table-x"
      hash_key                    = "id"
      range_key                   = "title"
      table_class                 = "STANDARD"
      deletion_protection_enabled = false

      attributes = [
        {
          name = "id"
          type = "N"
        },
        {
          name = "title"
          type = "S"
        },
        {
          name = "age"
          type = "N"
        }
      ]

      global_secondary_indexes = [
        {
          name               = "TitleIndex"
          hash_key           = "title"
          range_key          = "age"
          projection_type    = "INCLUDE"
          non_key_attributes = ["id"]
        }
      ]
    }
  }

  sqs_queues = {
    "queue-x" = {
      # Override configuration here
      content_based_deduplication     = true,
      deduplication_scope             = "messageGroup",
      delay_seconds                   = 10,
      dlq_content_based_deduplication = true,
      dlq_deduplication_scope         = "messageGroup",
      dlq_delay_seconds               = 20,
      dlq_message_retention_seconds   = 300,
      dlq_receive_wait_time_seconds   = 10,
      dlq_visibility_timeout_seconds  = 2,
      fifo_queue                      = true,
      fifo_throughput_limit           = "perMessageGroupId",
      max_message_size                = 1024,
      message_retention_seconds       = 1200,
      receive_wait_time_seconds       = 10,
      visibility_timeout_seconds      = 20,
      readwrite_arns                  = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
      read_arns                       = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
  }
}

# Only needed for the example to work
data "aws_caller_identity" "current" {}
