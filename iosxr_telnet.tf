resource "iosxr_telnet" "telnet" {
  for_each = { for device in local.devices : device.name => device if try(local.device_config[device.name].telnet, null) != null || try(local.defaults.iosxr.configuration.telnet, null) != null }
  device   = each.value.name

  ipv4_client_source_interface = try(local.device_config[each.value.name].telnet.ipv4_client_source_interface, local.defaults.iosxr.configuration.telnet.ipv4_client_source_interface, null)
  ipv6_client_source_interface = try(local.device_config[each.value.name].telnet.ipv6_client_source_interface, local.defaults.iosxr.configuration.telnet.ipv6_client_source_interface, null)

  vrfs      = try(local.device_config[each.value.name].telnet.vrfs, local.defaults.iosxr.configuration.telnet.vrfs, null)
  vrfs_dscp = try(local.device_config[each.value.name].telnet.vrfs_dscp, local.defaults.iosxr.configuration.telnet.vrfs_dscp, null)
}
