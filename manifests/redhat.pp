# File::      <tt>redhat.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache::redhat
#
# Specialization class for Redhat systems
class apache::redhat inherits apache::common {

    file { [
            '/usr/local/sbin/a2ensite',
            '/usr/local/sbin/a2dissite',
            '/usr/local/sbin/a2enmod',
            '/usr/local/sbin/a2dismod'
            ] :
                ensure => $apache::ensure,
                mode   => '0755',
                owner  => 'root',
                group  => 'root',
                source => 'puppet:///modules/apache/usr/local/sbin/a2X.redhat',
    }

    # Add dependency for the apache::module definition
    Apache::Module {
        require => [ File['/usr/local/sbin/a2enmod'], File['/usr/local/sbin/a2dismod'] ]
    }

    if ($apache::use_ssl) {
        package { 'mod_ssl' :
            ensure  => $apache::ensure,
            require => Package['apache2']
        }
    }

    # Enable php module
    apache::module {'php5':
        ensure => $apache::common::phpensure,
        notify => Exec[$apache::params::gracefulrestart],
    }

    # Add seltype 'httpd_config_t' for /etc/httpd and {mods,sites}-{enabled,available} files
    # TODO

    # this module is statically compiled on debian and must be enabled here
    apache::module { 'log_config':
        ensure => $apache::ensure,
        notify => Exec[$apache::params::gracefulrestart],
    }


}
