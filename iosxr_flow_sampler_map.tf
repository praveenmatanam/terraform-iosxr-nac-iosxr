locals {
  flow_sampler_maps = flatten([
    for device in local.devices : [
      for sampler_map in try(local.device_config[device.name].flow_sampler_maps, []) : {
        key         = "${device.name}-${sampler_map.name}"
        device_name = device.name
        name        = try(sampler_map.name, local.defaults.iosxr.devices.configuration.flow_sampler_maps.name, null)
        random      = try(sampler_map.random, local.defaults.iosxr.devices.configuration.flow_sampler_maps.random, null)
        out_of      = try(sampler_map.out_of, local.defaults.iosxr.devices.configuration.flow_sampler_maps.out_of, null)
      }
    ]
  ])
}

resource "iosxr_flow_sampler_map" "flow_sampler_map" {
  for_each = { for sampler_map in local.flow_sampler_maps : sampler_map.key => sampler_map }
  device   = each.value.device_name
  name     = each.value.name
  random   = each.value.random
  out_of   = each.value.out_of
}
