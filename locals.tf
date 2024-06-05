locals {
  prefix   = "${var.bu}-${var.project}"
  suffix   = var.env
  region   = var.region
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  tags = {
    Businessunit = var.bu
    Environment  = var.env
    TeamName     = "RnD"
    Managedby    = "Terraform"
  }

}
