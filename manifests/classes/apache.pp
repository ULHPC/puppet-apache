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
class apache(
    $ensure  = $apache::params::ensure,
    $use_ssl = $apache::params::use_ssl,
    $redirect_ssl = $apache::params::redirect_ssl
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

    $sslensure = $apache::use_ssl ? {
        true    => 'present',
        default => 'absent',
    }

    # Package to install
    package { 'apache2':
        name   => "${apache::params::packagename}",
        ensure => "${apache::ensure}",
    }

    if ($apache::use_ssl) {
        
        file { "${apache::params::generate_ssl_cert}":
            source  => "puppet:///modules/apache/generate-ssl-cert.sh",
            mode    => '0755',
            owner   => 'root',
            group   => 'root',
            ensure  => "${apache::ensure}",
            #require => Package['openssl']
        }

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
        path        => "/usr/bin:/usr/sbin/:/bin:/sbin",
        require     => Package['apache2'],
        onlyif      => "${apache::params::configtest}",
        refreshonly => true,
    }

    apache::module {'ssl':
        ensure => $sslensure,
        notify => Exec["${apache::params::gracefulrestart}"],
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
            owner   => "${apache::params::user}",
            group   => "${apache::params::group}",
            mode    => "${apache::params::wwwdir_mode}",
            require => File["${apache::params::wwwdir}"],
        }

        # ... and populate it with the default index.html
        file {"${apache::params::wwwdir}/default-html/index.html":
            ensure  => "${apache::ensure}",
            owner   => "${apache::params::user}",
            group   => "${apache::params::group}",
            mode    => "${apache::params::configfile_mode}",
            content => "<html><body><h1>It works! (default-html)</h1></body></html>\n",
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
        file { [
                "${apache::params::vhost_availabledir}",
                "${apache::params::vhost_enableddir}",
                "${apache::params::mods_availabledir}",
                "${apache::params::mods_enableddir}"
                ]:
                    owner   => "${apache::params::configdir_owner}",
                    group   => "${apache::params::configdir_group}",
                    mode    => "${apache::params::configdir_mode}",
                    ensure  => 'directory',
                    seltype => "${apache::params::configdir_seltype}",
                    notify  => Exec["${apache::params::gracefulrestart}"],
                    require => Package['apache2'],
        }

        # The default virtual host file
        file { "${apache::params::vhost_availabledir}/default":
            ensure  => "$apache::ensure",
            owner   => "${apache::params::configdir_owner}",
            group   => "${apache::params::configdir_group}",
            mode    => "${apache::params::configfile_mode}",
            seltype => "${apache::params::configdir_seltype}",
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

    if $apache::use_ssl {
        if !defined(Package['ca-certificates']) {
            package { 'ca-certificates':
                ensure => "${apache::ensure}",
            }
        }
    }


}

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
                ensure => "${apache::ensure}",
                mode   => '0755',
                owner  => 'root',
                group  => 'root',
                source => "puppet:///modules/apache/usr/local/sbin/a2X.redhat",
    }

    # Add dependency for the apache::module definition
    Apache::Module {
        require => [ File['/usr/local/sbin/a2enmod'], File['/usr/local/sbin/a2dismod'] ]
    }

    if ($apache::use_ssl) {
        package { 'mod_ssl' :
            ensure  => "${apache::ensure}",
            require => Package['apache2']
        }
    }

    # Add seltype 'httpd_config_t' for /etc/httpd and {mods,sites}-{enabled,available} files
    # TODO

    # this module is statically compiled on debian and must be enabled here
    apache::module { 'log_config':
        ensure => "${apache::ensure}",
        notify => Exec["${apache::params::gracefulrestart}"],
    }



}



