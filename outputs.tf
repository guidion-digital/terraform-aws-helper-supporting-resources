output "dyanmodb_table_stream_arns" {
  value = { for this_name, these_values in module.dynamodb_table : this_name => these_values.dynamodb_table_stream_arn }
}

output "dyanmodb_table_stream_arns_no_app_name_prefix" {
  value = { for this_name, these_values in module.dynamodb_table : trim(this_name, var.application_name) => these_values.dynamodb_table_stream_arn }
}
