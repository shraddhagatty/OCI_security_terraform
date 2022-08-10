# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    notify_on_network_changes_rule      = {key:"${var.customer_label}-notify-on-network-changes-rule",       name:"${var.customer_label}-notify-on-network-changes-rule"}
    notify_on_storage_changes_rule      = {key:"${var.customer_label}-notify-on-storage-changes-rule",       name:"${var.customer_label}-notify-on-storage-changes-rule"}
    notify_on_database_changes_rule     = {key:"${var.customer_label}-notify-on-database-changes-rule",      name:"${var.customer_label}-notify-on-database-changes-rule"}
    notify_on_compute_changes_rule      = {key:"${var.customer_label}-notify-on-compute-changes-rule",       name:"${var.customer_label}-notify-on-compute-changes-rule"}
    
  
  regional_notifications =  merge (
    {for i in [1] : (local.notify_on_network_changes_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to detect when networking resources are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createvcn",
          "com.oraclecloud.virtualnetwork.deletevcn",
          "com.oraclecloud.virtualnetwork.updatevcn",
          "com.oraclecloud.virtualnetwork.createroutetable",
          "com.oraclecloud.virtualnetwork.deleteroutetable",
          "com.oraclecloud.virtualnetwork.updateroutetable",
          "com.oraclecloud.virtualnetwork.changeroutetablecompartment",
          "com.oraclecloud.virtualnetwork.createsecuritylist",
          "com.oraclecloud.virtualnetwork.deletesecuritylist",
          "com.oraclecloud.virtualnetwork.updatesecuritylist",
          "com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
          "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroupsecurityrules",
          "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
          "com.oraclecloud.virtualnetwork.createdrg",
          "com.oraclecloud.virtualnetwork.deletedrg",
          "com.oraclecloud.virtualnetwork.updatedrg",
          "com.oraclecloud.virtualnetwork.createdrgattachment",
          "com.oraclecloud.virtualnetwork.deletedrgattachment",
          "com.oraclecloud.virtualnetwork.updatedrgattachment",
          "com.oraclecloud.virtualnetwork.createinternetgateway",
          "com.oraclecloud.virtualnetwork.deleteinternetgateway",
          "com.oraclecloud.virtualnetwork.updateinternetgateway",
          "com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment",
          "com.oraclecloud.virtualnetwork.createlocalpeeringgateway",
          "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway",
          "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
          "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
          "com.oraclecloud.natgateway.createnatgateway",
          "com.oraclecloud.natgateway.deletenatgateway",
          "com.oraclecloud.natgateway.updatenatgateway",
          "com.oraclecloud.natgateway.changenatgatewaycompartment",
          "com.oraclecloud.servicegateway.createservicegateway",
          "com.oraclecloud.servicegateway.deleteservicegateway.begin",
          "com.oraclecloud.servicegateway.deleteservicegateway.end",
          "com.oraclecloud.servicegateway.attachserviceid",
          "com.oraclecloud.servicegateway.detachserviceid",
          "com.oraclecloud.servicegateway.updateservicegateway",
          "com.oraclecloud.servicegateway.changeservicegatewaycompartment"
          ]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    }},
    {for i in [1] : (local.notify_on_storage_changes_rule.key) => {
      compartment_id      = local.storage_topic.cmp_id
      description         = "Landing Zone events rule to detect when storage resources are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.objectstorage.createbucket",
             "com.oraclecloud.objectstorage.deletebucket",
             "com.oraclecloud.blockvolumes.deletevolume.begin",
             "com.oraclecloud.filestorage.deletefilesystem"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    } if length(var.network_admin_email_endpoints) > 0},
    
    {for i in [1] : (local.notify_on_database_changes_rule.key) => {
      compartment_id      = local.database_topic.cmp_id       
      description         = "Landing Zone events rule to detect when database resources are created, updated or deleted in the database compartment."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            [${local.database_events}]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    } if length(var.network_admin_email_endpoints)  > 0},

     

    {for i in [1] : (local.notify_on_budget_changes_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to detect when cost resources such as budgets and financial tracking constructs are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.budgets.updatealertrule",
             "com.oraclecloud.budgets.deletealertrule",
             "com.oraclecloud.budgets.updatebudget",
             "com.oraclecloud.budgets.deletebudget"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    } if length(var.network_admin_email_endpoints) > 0},

    {for i in [1] : (local.notify_on_compute_changes_rule.key) => {
      compartment_id      = local.compute_topic.cmp_id
      description         = "Landing Zone events rule to detect when compute related resources are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.computeapi.terminateinstance.begin"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    } if length(var.network_admin_email_endpoints) > 0 }
  )
}


module "lz_notifications" {
  depends_on = [null_resource.slow_down_notifications]
  source     = "./modules/notifications"
  rules = local.regional_notifications
}



resource "null_resource" "slow_down_notifications" {
  #depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
  }
}
