# File::      <tt>apache-diskcache.pp</tt>
# Author::    Hyacinthe Cartiaux (Hyacinthe.Cartiaux@uni.lu)
# Copyright:: Copyright (c) 2013 Hyacinthe Cartiaux
# License::   GPLv3
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
    info ("Configuring apache::diskcache (with ensure = ${ensure}, use_ssl = ${use_ssl}, redirect_ssl = ${redirect_ssl})")

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
            fail("Module ${module_name} is not supported on ${operatingsystem}")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: apache::diskcache::common
#
# Base class to be inherited by the other apache classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class apache::diskcache::common {

    # Load the variables used in this module. Check the apache-params.pp file
    require apache::params

    # Activate the rewrite module for automatic SSL redirection
    apache::module { 'disk_cache':
        ensure => $apache::diskcache::ensure,
        notify => Exec[$apache::params::gracefulrestart],
    }


    # The default virtual host file
    file { "${mods_availabledir}/disk_cache.conf":
        ensure  => $apache::diskcache::ensure,
        owner   => $apache::params::configdir_owner,
        group   => $apache::params::configdir_group,
        mode    => $apache::params::configfile_mode,
        seltype => $apache::params::configdir_seltype,
        content => template("apache/${apache::params::disk_cache_template}"),
    }
}


# ------------------------------------------------------------------------------
# = Class: apache::diskcache::debian
#
# Specialization class for Debian systems
class apache::diskcache::debian inherits apache::diskcache::common { }

# ------------------------------------------------------------------------------
# = Class: apache::diskcache::redhat
#
# Specialization class for Redhat systems
class apache::diskcache::redhat inherits apache::diskcache::common { }



