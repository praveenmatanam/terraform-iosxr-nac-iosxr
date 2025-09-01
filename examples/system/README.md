<!-- BEGIN_TF_DOCS -->
# IOS-XR Hostname Configuration Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

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
<!-- END_TF_DOCS -->