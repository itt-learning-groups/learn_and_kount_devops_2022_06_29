variable "bucket_name" {
  type = string
}

variable "destroy_s3_objects" {
  type    = bool
  default = true
}

variable "admin_group_name" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "admin_role" {
  type = string
}
