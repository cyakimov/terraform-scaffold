variable "test_value" {
}

variable "equal_to_value" {
}

variable "then_result" {
}

variable "else_result" {
}

// if value==equal_to_value then then_result else else_result

output "result" {
  value = "${replace(replace(var.else_result, replace(var.test_value, "/^${var.equal_to_value}$/", "/^.*$/"), ""), "/^$/", var.then_result)}"
}
