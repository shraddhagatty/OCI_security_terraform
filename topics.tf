# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals  {
  # Topics
  # id is for future use
  network_topic     = {key: "NETWORK-TOPIC",    name: "${var.customer_label}-network-topic",    cmp_id: module.iam.compartments["common_services"], id : null}


  regional_topics = merge(
      {for i in [1] :  (local.network_topic.key) => {
        compartment_id = local.network_topic.cmp_id
        name           = local.network_topic.name
        description    = "Landing Zone topic for network related notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.network_admin_email_endpoints) > 0},
    
  )  
}

module "lz_topics" {
  source     = "./modules/topics"
  depends_on = [ null_resource.slow_down_topics ]
  topics     = local.regional_topics
}


module "lz_subscriptions" {
  source        = "./modules/subscriptions"
  subscriptions = merge(
    { for e in var.network_admin_email_endpoints: "${e}-${local.network_topic.name}" => {
        compartment_id = local.network_topic.cmp_id
        topic_id       = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
        protocol       = "EMAIL" 
        endpoint       = e
        defined_tags   = null
        freeform_tags  = null
    }}
    
  )
}

resource "null_resource" "slow_down_topics" {
   #depends_on = [ module.lz_compartments ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
   }
}