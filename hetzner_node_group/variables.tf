## ----- general configuration -------------------------------------------------

variable "ssh_public_key" {
  description = "ID of the public SSH key to configure on the nodes."
  type        = string
}

variable "ssh_private_key" {
  description = "Path to the private SSH key to setup the nodes."
  type        = string
}

## ----- cluster configuration -------------------------------------------------

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "cluster_network" {
  description = "Network ID of the cluster."
  type        = string
}

variable "cluster_location" {
  description = "Hetzner Cloud Location."
  type        = string
  default     = "nbg1"

  validation {
    condition     = contains(["nbg1", "fsn1", "hel1", "ash", "hil"], var.cluster_location)
    error_message = "Location must be either \"nbg1\", \"fsn1\", \"hel1\", \"ash\" or \"hil\"."
  }
}

## ----- node configuration ----------------------------------------------------

variable "node_group" {
  description = "Name of the node group."
  type        = string
}

variable "node_prefix" {
  description = "Prefix for the node names."
  type        = string
  default     = "node"
}

variable "node_count" {
  description = "Number of nodes in the group."
  type        = number
  default     = 3
}

variable "node_type" {
  description = "Machine type of the nodes."
  type        = string
  default     = "cx22"

  validation {
    condition     = contains(["cx22", "cx32", "cx42", "cx52", "cpx11", "cpx21", "cpx31", "cpx41", "cpx51"], var.node_type)
    error_message = "Type must be either \"cx(2|3|4|5)2\" or \"cpx(2|3|4|5)1\"."
  }
}

## ----- public network --------------------------------------------------------

variable "public_ipv4" {
  description = "Enable public IPv4."
  type        = bool
  default     = false
}

variable "public_ipv6" {
  description = "Enable public IPv6."
  type        = bool
  default     = false
}
