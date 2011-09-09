# File::      <tt>apache.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
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
#     import apache
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'apache':
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
class apache( $ensure = $apache::params::ensure ) inherits apache::params
{
    info ("Configuring apache (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include apache::debian }
        redhat, fedora, centos: { include apache::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: apache::common
#
# Base class to be inherited by the other apache classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class apache::common {

    # Load the variables used in this module. Check the apache-params.pp file
    require apache::params

    # Package to install
    package { 'apache2':
        name    => "${apache::params::packagename}",
        ensure  => "${apache::ensure}",
    }

    # Apache user
    user { "${apache::params::user}":
        ensure  => "${apache::ensure}",
        require => Package['apache2'],
        shell   => '/bin/sh',
    }
    # Apache group
    group { "${apache::params::group}":
        ensure  => "${apache::ensure}",
        require => Package['apache2']
    }

    # Graceful restart of the apache server
    exec { "${apache::params::gracefulrestart}":
        refreshonly => true,
        onlyif      => "${apache::params::configtest}",
    }

    
    if $apache::ensure == 'present' {

        # main root configuration dir (/etc/apache2 on Debian systems)
        file { "${apache::params::configdir}":
            owner   => "${apache::params::configdir_owner}",
            group   => "${apache::params::configdir_group}",
            mode    => "${apache::params::configdir_mode}",
            ensure  => 'directory',
            require => Package['apache2'],
        }

        # Where to put www data
        file { "${apache::params::wwwdir}":
            ensure  => 'directory',
            owner   => "${apache::params::wwwdir_owner}",
            group   => "${apache::params::wwwdir_group}",
            mode    => "${apache::params::wwwdir_mode}",
            require => Package['apache2'],
        }

        # disable default index.html
        file {"${apache::params::wwwdir}/index.html":
            ensure => absent,
        }

        # Create the directory to host the default index.html
        file {"${apache::params::wwwdir}/default-html":
            ensure  => 'directory',
            owner   => "${apache::params::wwwdir_owner}",
            group   => "${apache::params::wwwdir_group}",
            mode    => "${apache::params::wwwdir_mode}",
            require => File["${apache::params::wwwdir}"],
        }

        # ... and populate it with the default index.html
        file {"${apache::params::wwwdir}/default-html/index.html":
            ensure  => "${apache::ensure}",
            owner   => "${apache::params::wwwdir_owner}",
            group   => "${apache::params::wwwdir_group}",
            mode    => "${apache::params::configfile_mode}",
            content => "<html><body><h1>It works!</h1></body></html>\n",
            require => File["${apache::params::wwwdir}/default-html"],
            notify  => Exec["${apache::params::gracefulrestart}"],
        }

        # CGI bin directory
        file { "${apache::params::cgidir}":
            owner   => "${apache::params::cgidir_owner}",
            group   => "${apache::params::cgidir_group}",
            mode    => "${apache::params::cgidir_mode}",
            ensure  => 'directory',
            require => Package['apache2'],
        }

        # Apache Logs directory
        file { "${apache::params::logdir}":
            owner   => "${apache::params::logdir_owner}",
            group   => "${apache::params::logdir_group}",
            mode    => "${apache::params::logdir_mode}",
            ensure  => 'directory',
            require => Package['apache2'],
        }

        # Apache virtual host dir (both available and enabled)
        file { [ "${apache::params::vhost_availabledir}", "${apache::params::vhost_enableddir}" ]:
            owner   => "${apache::params::configdir_owner}",
            group   => "${apache::params::configdir_group}",
            mode    => "${apache::params::configdir_mode}",
            ensure  => 'directory',
            notify  => Exec["${apache::params::gracefulrestart}"],
            require => Package['apache2'],
        }

        # The default virtual host file
        file { "${apache::params::vhost_availabledir}/default":
            ensure  => "$apache::ensure",
            owner   => "${apache::params::configdir_owner}",
            group   => "${apache::params::configdir_group}",
            mode    => "${apache::params::configfile_mode}",
            content => template("apache/${apache::params::vhost_default}"),
            require => File["${apache::params::vhost_availabledir}"],
        }


        # TODO: remove default-ssl? 

        


        
        service { 'apache2':
            name       => "${apache::params::servicename}",
            enable     => true,
            ensure     => running,
            hasrestart => "${apache::params::hasrestart}",
            pattern    => "${apache::params::processname}",
            hasstatus  => "${apache::params::hasstatus}",
            require    => Package['apache2'],
        }



    }
    else
    {
        # Here $apache::ensure is 'absent'

    }
}


# ------------------------------------------------------------------------------
# = Class: apache::debian
#
# Specialization class for Debian systems
class apache::debian inherits apache::common {
    package { 'apache2-mpm-prefork':
        ensure  => "${apache::ensure}",
        require => Package['apache2'],
    }

}

# ------------------------------------------------------------------------------
# = Class: apache::redhat
#
# Specialization class for Redhat systems
class apache::redhat inherits apache::common { }



