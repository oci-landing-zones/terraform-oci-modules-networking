variable "custom_label" {
  type = string
}

variable "default_label" {
  type = string
}

variable "instances" {
  type = map(string)
}

resource "terraform_data" "custom" {
  for_each = var.instances
  input    = "${var.custom_label}:${each.key}:${each.value}"
}

resource "terraform_data" "default" {
  for_each = var.instances
  input    = "${var.default_label}:${each.key}:${each.value}"
}
