# File::      <tt>common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache::diskcache
#
# Manages apache mod disk cache
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of apache::diskcache
#
# == Actions:
#
# Install and configure apache disk cache
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import apache::diskcache
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'apache::diskcache':
#             arg => 'val'
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
class apache::diskcache(
    $ensure                 = $apache::params::ensure,
    $cache_root             = $apache::params::cache_root,
    $cache_path             = $apache::params::cache_path,
    $cachedirlevels         = $apache::params::cachedirlevels,
    $cachedirlength         = $apache::params::cachedirlength,
    $cachemaxfilesize       = $apache::params::cachemaxfilesize,
    $cacheignorenolastmod   = $apache::params::cacheignorenolastmod,
    $cachemaxexpire         = $apache::params::cachemaxexpire,
    $cacheignorequerystring = $apache::params::cacheignorequerystring
)
inherits apache::params
{
    info ("Configuring apache::diskcache (with ensure = ${ensure}, use_ssl = ${::use_ssl}, redirect_ssl = ${::redirect_ssl})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    if (! defined(Class['apache'])) {
        fail('Class apache is not instencied')
    }

    case $::operatingsystem {
        debian, ubuntu:         { include apache::diskcache::debian }
        redhat, fedora, centos: { include apache::diskcache::redhat }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}
