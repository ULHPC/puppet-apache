# File::      <tt>init.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache
#
# Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of apache
#
# == Actions:
#
# Install and configure apache
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     include 'apache'
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'apache':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class apache(
    $ensure  = $apache::params::ensure,
    $use_ssl = $apache::params::use_ssl,
    $use_php = $apache::params::use_php,
    $redirect_ssl = $apache::params::redirect_ssl,
    $enable_default_listen = true
)
inherits apache::params
{
    info ("Configuring apache (with ensure = ${ensure}, use_ssl = ${use_ssl}, redirect_ssl = ${redirect_ssl})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include apache::debian }
        redhat, fedora, centos: { include apache::redhat }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}



