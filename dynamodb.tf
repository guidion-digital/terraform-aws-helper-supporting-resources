# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CheatSheet.html
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-dynamodb-table-globalsecondaryindex.html
module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.3.0"

  for_each = var.dynamodb_tables

  name                                  = var.namespacing_enabled ? "${var.application_name}-${each.key}" : each.key
  billing_mode                          = each.value.billing_mode
  read_capacity                         = each.value.read_capacity
  write_capacity                        = each.value.write_capacity
  autoscaling_enabled                   = each.value.autoscaling_enabled
  ignore_changes_global_secondary_index = each.value.ignore_changes_global_secondary_index
  ttl_attribute_name                    = each.value.ttl_attribute_name
  ttl_enabled                           = each.value.ttl_attribute_name != "" ? true : false
  stream_enabled                        = true
  stream_view_type                      = each.value.stream_view_type
  point_in_time_recovery_enabled        = each.value.point_in_time_recovery_enabled
  timeouts                              = each.value.timeouts
  tags                                  = var.tags

  autoscaling_read = {
    scale_in_cooldown  = each.value.autoscaling_read_scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_read_scale_out_cooldown
    target_value       = each.value.autoscaling_read_target_value
    max_capacity       = each.value.autoscaling_read_max_capacity
  }

  autoscaling_write = {
    scale_in_cooldown  = each.value.autoscaling_write_scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_write_scale_out_cooldown
    target_value       = each.value.autoscaling_write_target_value
    max_capacity       = each.value.autoscaling_write_max_capacity
  }

  attributes = each.value.attributes
  hash_key   = each.value.hash_key
  range_key  = lookup(each.value, "range_key", null)

  global_secondary_indexes = each.value.global_secondary_indexes

  # N.B. We will need to do a merge() here if we want to include global_local_indexes
  autoscaling_indexes = { for this_index, these_values in { for this_index, these_values in each.value.global_secondary_indexes : these_values.name => these_values.autoscaling if these_values.autoscaling != null } : this_index => {
    read_max_capacity  = these_values.read_max_capacity,
    read_min_capacity  = these_values.read_min_capacity,
    write_max_capacity = these_values.write_max_capacity,
    write_min_capacity = these_values.write_min_capacity
    }
  }
}
