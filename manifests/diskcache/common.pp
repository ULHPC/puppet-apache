# File::      <tt>discache/common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
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
    file { "${apache::params::mods_availabledir}/disk_cache.conf":
        ensure  => $apache::diskcache::ensure,
        owner   => $apache::params::configdir_owner,
        group   => $apache::params::configdir_group,
        mode    => $apache::params::configfile_mode,
        seltype => $apache::params::configdir_seltype,
        content => template("apache/${apache::params::disk_cache_template}"),
    }
}
