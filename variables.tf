variable "token" {
  description = "Token"
  type        = string
}

variable "cloud_id" {
  description = "Token"
  type        = string
}

variable "folder_id" {
  description = "Folder ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "labels" {
  description = "Labels"
  type        = map(string)
}

variable "default_zone" {
  description = "Default zone"
  type        = string
}
