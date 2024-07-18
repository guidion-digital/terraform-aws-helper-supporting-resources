output "dyanmodb_table_stream_arns" {
  value = { for this_name, these_values in module.dynamodb_table : trim(this_name, var.application_name) => these_values.dynamodb_table_stream_arn }
}
