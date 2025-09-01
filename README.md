<!-- BEGIN_TF_DOCS -->
# Terraform Network-as-Code Cisco IOS-XR Module

A Terraform module to configure Cisco IOS-XR devices.

## Usage

This module supports an inventory driven approach, where a complete IOS-XR configuration or parts of it are either modeled in one or more YAML files or natively using Terraform variables.

## Examples

Configuring an IOS-XR hostname configuration using YAML:

#### `system.nac.yaml`

```yaml
iosxr:
  devices:
    - name: router-1
      host: 1.2.3.4
      configuration:
        hostname: router-1
        banner:
          - banner_type: "login"
            line: "#Hello user ! Welcome to IOS-XR device.#"
          - banner_type: "motd"
            line: "#System maintained by NAC Infrastructure as Code#"
          - banner_type: "exec"
            line: "#Exec Banner#"
          - banner_type: "incoming"
            line: "#Incoming connection banner#"
          - banner_type: "prompt-timeout"
            line: "#Session timeout warning#"
          - banner_type: "slip-ppp"
            line: "#SLIP/PPP connection banner#"
        service_timestamps:
          debug_datetime_localtime: true
          debug_datetime_msec: true
          debug_datetime_show_timezone: true
          debug_datetime_year: true
          debug_uptime: false
          debug_disable: false
          log_datetime_localtime: true
          log_datetime_msec: true
          log_datetime_show_timezone: true
          log_datetime_year: true
          log_uptime: false
          log_disable: false
        lldp:
          holdtime: 50
          timer: 6
          reinit: 3
          subinterfaces_enable: true
          priorityaddr_enable: true
          extended_show_width_enable: true
          tlv_select_management_address_disable: true
          tlv_select_port_description_disable: true
          tlv_select_system_capabilities_disable: true
          tlv_select_system_description_disable: true
          tlv_select_system_name_disable: true
```

#### `main.tf`

```hcl
module "iosxr" {
  source  = "netascode/nac-iosxr/iosxr"
  version = ">= 0.1.0"

  yaml_files = ["system.nac.yaml"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_iosxr"></a> [iosxr](#requirement\_iosxr) | >= 0.5.3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.2.6 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | `[]` | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_values"></a> [default\_values](#output\_default\_values) | All default values. |
| <a name="output_model"></a> [model](#output\_model) | Full model. |
## Resources

| Name | Type |
|------|------|
| [iosxr_banner.banner](https://registry.terraform.io/providers/CiscoDevNet/iosxr/latest/docs/resources/banner) | resource |
| [iosxr_hostname.hostname](https://registry.terraform.io/providers/CiscoDevNet/iosxr/latest/docs/resources/hostname) | resource |
| [iosxr_lldp.lldp](https://registry.terraform.io/providers/CiscoDevNet/iosxr/latest/docs/resources/lldp) | resource |
| [iosxr_service_timestamps.service_timestamps](https://registry.terraform.io/providers/CiscoDevNet/iosxr/latest/docs/resources/service_timestamps) | resource |
| [local_sensitive_file.defaults](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [terraform_data.validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
## Modules

No modules.
<!-- END_TF_DOCS -->