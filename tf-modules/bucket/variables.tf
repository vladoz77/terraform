variable "bucket_name" {
  type = string
  description = "bucket name"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the bucket."
  default     = {}
}

variable "acl" { 
    type = string
    description = "acl bucket"
}

variable "index" {
    default = "index.html"
    type = string
    description = "site file"
}

variable "versioning_enable" {
  default = true
  type = bool
  description = "enable versioning"
}


variable "rules" {
  description = "config lifecicle rules"
  type = list(object({
    id = optional(string)
    enabled = optional(bool, false)
    prefix = optional(string)
    days = optional(number)
  }))
  default = [ ]
}