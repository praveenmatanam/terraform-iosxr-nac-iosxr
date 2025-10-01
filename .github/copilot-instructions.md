# GitHub Copilot Instructions for IOS XR NAC Terraform Module

## Project Overview

This is a Terraform module for **Network as Code (NAC)** configuration of **Cisco IOS XR devices**. The module uses YAML-based configuration files to deploy network settings to IOS XR routers via the CiscoDevNet IOS XR Terraform provider.

## Core Architecture Patterns

### 1. Module Structure
- Each IOS XR feature has its own `.tf` file (e.g., `iosxr_router_ospf.tf`, `iosxr_bgp.tf`)
- Follow the naming pattern: `iosxr_<feature_name>.tf`
- Each module file contains both `locals` blocks and `resource` blocks

### 2. Data Flow Pattern
```
YAML Configuration → locals processing → Terraform resource → IOS XR device
```

### 3. Key Generation Pattern
**ALWAYS** use this pattern for resource keys:
```terraform
key = "${device.name}-${feature_specific_identifier}"
```

Examples:
- OSPF: `"${device.name}-${ospf_process.process_name}"`
- BGP: `"${device.name}-${bgp_process.as_number}"`
- Interface: `"${device.name}-${interface.name}"`

## YAML Configuration Patterns

### Device Structure
```yaml
iosxr:
  devices:
    - name: router-1                    # Device identifier
      host: 10.1.1.1:2627              # Device connection details
      configuration:
        feature_name:                   # IOS XR feature block
          - item_config                 # List of feature instances
```

### Feature Configuration Types
1. **List-based features** (multiple instances per device):
   - Simple lists: OSPF processes, Banner configurations
   - Complex nested lists: Key chains (with nested keys), Interfaces (with sub-interfaces)
   - Use list structure: `feature_name: [...]`
   
2. **Single-instance features** (one per device):
   - Global settings: Hostname, LACP, Logging, Domain
   - Use object structure: `feature_name: {...}`

3. **Hybrid features**:
   - NTP: Can have multiple servers but single global config
   - Uses mixed approach with both list and object patterns

## Terraform Code Patterns

### 1. List-Based Features (Multiple Instances)
For features like OSPF, BGP, banner, key_chain that can have multiple instances per device:

```terraform
locals {
  device_<feature_name> = flatten([
    for device in local.devices : [
      for <item> in try(local.device_config[device.name].<feature_name>, []) : {
        device_name = device.name
        key         = "${device.name}-${<item>.<identifier>}"
        
        # Map all attributes with defaults fallback
        attribute_name = try(<item>.attribute_name, local.defaults.iosxr.configuration.<feature_name>.attribute_name, null)
        
        # Handle nested lists/objects (e.g., key_chain keys)
        nested_items = [
          for nested in try(<item>.nested_items, []) : {
            nested_attr = try(nested.nested_attr, local.defaults.iosxr.configuration.<feature_name>.nested_items.nested_attr, null)
          }
        ]
      }
    ]
    if try(local.device_config[device.name].<feature_name>, null) != null
  ])
}
```

**Examples from actual codebase:**
- **Banner**: `"${device.name}-${banner.banner_type}"` 
- **Key Chain**: `"${device.name}-keychain-${key_chain.name}"`
- **OSPF**: `"${device.name}-${ospf_process.process_name}"`

### 2. Single-Instance Features (Global Settings)
For features like hostname, domain, LACP, logging that have one configuration per device:

```terraform
resource "iosxr_<feature_name>" "<feature_name>" {
  for_each = { 
    for device in local.devices : device.name => device 
    if try(local.device_config[device.name].<feature_name>, null) != null || 
       try(local.defaults.iosxr.configuration.<feature_name>, null) != null 
  }
  device = each.value.name

  # Direct attribute mapping without locals processing
  attribute_name = try(local.device_config[each.value.name].<feature_name>.attribute_name, local.defaults.iosxr.configuration.<feature_name>.attribute_name, null)
}
```

**Examples from actual codebase:**
- **Hostname**: Single string value per device
- **Logging**: Multiple attributes but single instance per device
- **LACP**: System-wide settings, one configuration per device

### 3. Resource Block Structure for List-Based Features
```terraform
resource "iosxr_<feature_name>" "<feature_name>" {
  for_each = { for item in local.device_<feature_name> : item.key => item }

  device = each.value.device_name
  
  # Map all attributes from locals
  attribute_name = each.value.attribute_name
  nested_items   = each.value.nested_items
}
```

## Defaults Handling

### Attribute-Level Defaults
Use nested object structure for defaults:
```terraform
# CORRECT
local.defaults.iosxr.configuration.<feature_name>.attribute_name

# INCORRECT  
local.defaults.iosxr.configuration.<feature_name>_attribute_name
```

### List-Level Defaults
**Do NOT support defaults for list items** - only support defaults at the attribute level within each list item.

### Try Pattern
Always use this pattern for attribute mapping:
```terraform
attribute_name = try(item.attribute_name, local.defaults.iosxr.configuration.<feature_name>.attribute_name, null)
```

### Inconsistent Patterns Found in Existing Code
Some older modules use inconsistent patterns that should be avoided:

**❌ AVOID: Flat defaults structure (found in interface.tf)**
```terraform
# OLD PATTERN - Don't use
local.defaults.iosxr.configuration.interface_mtu
```

**❌ AVOID: Mixed defaults patterns (found in banner.tf)**
```terraform
# INCONSISTENT PATTERN - Don't replicate
try(banner.banner_type, local.defaults.iosxr.configuration.banner_type, null)
try(local.device_config[device.name].banner, local.defaults.iosxr.configuration.banner, [])
```

**✅ USE: Nested defaults structure**
```terraform
# NEW PATTERN - Use this
local.defaults.iosxr.configuration.interface.mtu
local.defaults.iosxr.configuration.banner.banner_type
local.defaults.iosxr.configuration.key_chain.keys.key_name
```

## Naming Conventions

### Files and Resources
- File: `iosxr_<feature_name>.tf`
- Locals: `device_<feature_name>`
- Resource: `iosxr_<feature_name>.<feature_name>`

### Variables and Attributes
- Use snake_case for all Terraform variables
- Match IOS XR provider attribute names exactly
- Use descriptive names that match IOS XR CLI commands

### YAML Keys
- Use snake_case for consistency with Terraform
- Match IOS XR provider attribute names when possible
- Use clear, self-documenting names

## Error Handling Patterns

### Required Attributes
Use `try()` with appropriate fallbacks:
```terraform
# With default fallback
attribute = try(item.attribute, local.defaults.iosxr.configuration.feature.attribute, null)

# Without default (optional attribute)
attribute = try(item.attribute, null)
```

### Conditional Resources
Always include existence check:
```terraform
if try(local.device_config[device.name].<feature_name>, null) != null
```

## Testing Patterns

### Example Configurations
- Provide comprehensive examples in `examples/` directory
- Use realistic network scenarios
- Include both basic and advanced configurations

### Validation
- Always test with `terraform plan` first
- Verify resource key generation is correct
- Test both apply and destroy operations
- Validate on actual IOS XR devices when possible

## Advanced Configuration Patterns

### Interface Groups and Complex Merging
Some modules support complex configuration merging with YAML references:

```terraform
# Example from iosxr_interface.tf
interface_groups = try(local.device_config[device.name].interface_groups, {})
merged_config    = try(local.device_config[device.name].interfaces[each.key], yamldecode(yaml_merge(
  yamlencode(local.interface_groups[each.value.interface_group]),
  yamlencode(local.device_config[device.name].interfaces[each.key])
)), {})
```

This pattern allows:
- Interface group templates with shared configurations
- Per-interface overrides that merge with group settings
- Complex YAML structure handling with `yamldecode` and `yaml_merge`

### Pre-commit Hook Integration
The project uses automated code quality checks:
- `terraform fmt`: Automatic formatting
- `tflint`: Linting and validation 
- `terraform-docs`: Documentation generation

Ensure all modules comply with these standards.

## Code Quality Standards

### Formatting
- Use `terraform fmt` for consistent formatting
- Align attribute assignments for readability
- Use consistent indentation (2 spaces)

### Comments
- Document complex logic in locals blocks
- Explain non-obvious attribute mappings
- Add comments for IOS XR-specific behavior

### Modularity
- Keep each feature in its own file
- Avoid cross-feature dependencies
- Make each feature independently configurable

## Provider Patterns

### Device Configuration
```terraform
provider "iosxr" {
  alias = "device_name"
}
```

### Authentication
Use environment variables:
- `IOSXR_USERNAME`
- `IOSXR_PASSWORD` 
- `IOSXR_HOST`
- `IOSXR_TLS`

## Common IOS XR Feature Patterns

### Process-Based Features (OSPF, BGP, ISIS)
- Always include `process_name` or equivalent identifier
- Support multiple processes per device
- Use process identifier in resource key

### Interface-Based Features
- Use interface name as identifier
- Support interface hierarchies (physical, sub-interfaces)
- Handle interface-specific attributes

### Global Features (Hostname, Domain)
- Single instance per device
- Use device name as identifier
- Simpler locals structure (no list iteration)

## Performance Considerations

### Resource Creation
- Use `for_each` instead of `count` for better resource tracking
- Generate stable resource keys for consistent state management
- Minimize resource churn during updates

### State Management
- Ensure resource keys remain stable across configuration changes
- Use meaningful identifiers that won't change frequently
- Avoid complex computed keys when possible

## Security Best Practices

### Credentials
- Never hardcode credentials in configuration files
- Use environment variables or secure credential stores
- Support multiple authentication methods

### Network Access
- Support TLS encryption when available
- Validate device certificates when possible
- Use secure protocols for device communication

## Continuous Learning Protocol

### Documentation Evolution
- **Always update this file immediately** when discovering new patterns, issues, or solutions
- Document workarounds for provider limitations or IOS XR quirks
- Record debugging techniques that prove effective
- Note performance optimizations discovered during testing
- Capture configuration patterns that work well in production

### Learning Categories to Track
1. **Provider Behavior**: Undocumented IOS XR provider behaviors or limitations
2. **Device Quirks**: IOS XR device-specific configuration requirements
3. **Performance Patterns**: Terraform resource management optimizations
4. **Debugging Techniques**: Effective troubleshooting approaches
5. **Configuration Patterns**: YAML structure patterns that work well
6. **Testing Insights**: Validation approaches for complex configurations

---

## Quick Reference

### New Feature Checklist
- [ ] Create `iosxr_<feature>.tf` file
- [ ] Implement locals block with proper key generation
- [ ] Add resource block with for_each pattern
- [ ] Support defaults with nested object structure
- [ ] Add example configuration in `examples/`
- [ ] Test on actual IOS XR device
- [ ] Verify terraform fmt compliance
- [ ] Document any feature-specific patterns
- [ ] **Update copilot-instructions.md with new learnings**

### Key Generation Formula
```
"${device.name}-${unique_identifier_from_config}"
```

### Defaults Pattern
```
try(item.attr, local.defaults.iosxr.configuration.feature.attr, null)
```