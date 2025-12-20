variable "env" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "prod"
  
}
variable "instance_type" {
  description = "The type of AWS EC2 instance to launch"
  type        = string
  default     = "t2.micro"
  
}
# EXPLANATION: A Map used for 'for_each'. 
# Keys (checkout, search) become unique identifiers. Values (admin, viewer) are data
variable "team_settings" {
  description = "Settings for the team"
type = map(object({ role = string }))
  default = {
    "checkout" = { role = "admin" }
    "search"   = { role = "viewer" }
  }
}