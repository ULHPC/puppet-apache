# File::      <tt>debian.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache::debian
#
# Specialization class for Debian systems
class apache::debian inherits apache::common {

    # Ensure package lists are updated before attempting package installation.
    exec { 'apt-update':
      command => '/usr/bin/apt-get update'
    }
    Exec['apt-update'] -> Package <| |>

    package { 'apache2-mpm-prefork':
        ensure  => $apache::ensure,
        require => Package['apache2'],
    }

    if $apache::use_ssl {
        if !defined(Package['ca-certificates']) {
            package { 'ca-certificates':
                ensure => $apache::ensure,
            }
        }

        if ($::lsbdistcodename in ['squeeze', 'wheezy']) {
            # SSL configuration
            file { "${apache::params::mods_availabledir}/ssl.conf":
                ensure  => $apache::ensure,
                owner   => $apache::params::configdir_owner,
                group   => $apache::params::configdir_group,
                mode    => $apache::params::configfile_mode,
                seltype => $apache::params::configdir_seltype,
                source  => "puppet:///modules/apache/conf_${::lsbdistcodename}/ssl.conf",
                notify  => Exec[$apache::params::gracefulrestart],
            }
        }

    }

    # Apache security configuration
    file { "${apache::params::otherconfigdir}/security":
        ensure  => $apache::ensure,
        owner   => $apache::params::configdir_owner,
        group   => $apache::params::configdir_group,
        mode    => $apache::params::configfile_mode,
        seltype => $apache::params::configdir_seltype,
        source  => 'puppet:///modules/apache/security',
        notify  => Exec[$apache::params::gracefulrestart],
    }

}
