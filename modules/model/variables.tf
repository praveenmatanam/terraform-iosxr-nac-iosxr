variable "yaml_directories" {
  description = "List of paths to YAML directories."
  type        = list(string)
  default     = []
}

variable "yaml_files" {
  description = "List of paths to YAML files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
  validation {
    condition     = length(var.yaml_directories) != 0 || length(var.yaml_files) != 0 || length(keys(var.model)) != 0
    error_message = "Either `yaml_directories`,`yaml_files` or a non-empty `model` value must be provided."
  }
}

variable "managed_device_groups" {
  description = "List of device group names to be managed. By default all device groups will be managed."
  type        = list(string)
  default     = []
}

variable "managed_devices" {
  description = "List of device names to be managed. By default all devices will be managed."
  type        = list(string)
  default     = []
}

variable "write_default_values_file" {
  description = "Write all default values to a YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}

variable "write_model_file" {
  type        = string
  description = "Write the rendered device model to a single YAML file. Value is a path pointing to the file to be created."
  default     = ""
}
