
locals {

  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.this.home_region_key                         # Home region key obtained from the tenancy data source
  region_key          = lower(local.regions_map_reverse[var.region])     

# Policy names
  services_policy_name   = "${var.customer_label}-services-policy"
  use_existing_tenancy_policies = var.policies_in_root_compartment == "CREATE" ? false : true

# CLOUD GUARD
  cg_target_name = "${var.customer_label}-cloud-guard-root-target"

  cloud_guard_statements = ["Allow service cloudguard to read keys in tenancy",
                            "Allow service cloudguard to read compartments in tenancy",
                            "Allow service cloudguard to read tenancies in tenancy",
                            "Allow service cloudguard to read audit-events in tenancy",
                            "Allow service cloudguard to read compute-management-family in tenancy",
                            "Allow service cloudguard to read instance-family in tenancy",
                            "Allow service cloudguard to read virtual-network-family in tenancy",
                            "Allow service cloudguard to read volume-family in tenancy",
                            "Allow service cloudguard to read database-family in tenancy",
                            "Allow service cloudguard to read object-family in tenancy",
                            "Allow service cloudguard to read load-balancers in tenancy",
                            "Allow service cloudguard to read users in tenancy",
                            "Allow service cloudguard to read groups in tenancy",
                            "Allow service cloudguard to read policies in tenancy",
                            "Allow service cloudguard to read dynamic-groups in tenancy",
                            "Allow service cloudguard to read authentication-policies in tenancy",
                            "Allow service cloudguard to use network-security-groups in tenancy"]

 # Vulnerablity Scanning
  scan_default_recipe_name = "${var.customer_label}-default-scan-recipe"

  vss_statements       = ["Allow service vulnerability-scanning-service to manage instances in tenancy",
                          "Allow service vulnerability-scanning-service to read compartments in tenancy",
                          "Allow service vulnerability-scanning-service to read vnics in tenancy",
                          "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"]

 # OS Management

  os_mgmt_statements     = ["Allow service osms to read instances in tenancy"]

  # Delay in seconds for slowing down resource creation
  delay_in_secs = 70

}
