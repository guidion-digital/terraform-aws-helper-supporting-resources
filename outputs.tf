output "dyanmodb_table_stream_arns" {
  value = { for this_name, these_values in module.dynamodb_table : (var.namespacing_enabled ? "${var.application_name}-${this_name}" : this_name) => these_values.dynamodb_table_stream_arn }
}

output "dyanmodb_table_stream_arns_no_app_name_prefix" {
  value = { for this_name, these_values in module.dynamodb_table : trim(this_name, var.application_name) => these_values.dynamodb_table_stream_arn }
}

output "dynamodb" {
  value = module.dynamodb_table
}

output "sqs" {
  value = var.sqs_queues
}
