# File::      <tt>common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache::common
#
# Base class to be inherited by the other apache classes, containing the common code.
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class apache::common {

    # Load the variables used in this module. Check the params.pp file
    require apache::params

    $sslensure = $apache::use_ssl ? {
        true    => 'present',
        default => 'absent',
    }
    $phpensure = $apache::use_php ? {
        true    => 'present',
        default => 'absent',
    }

    # Package to install
    package { 'apache2':
        ensure => $apache::ensure,
        name   => $apache::params::packagename,
    }

    package { $apache::params::php_packages:
        ensure => $phpensure
    }

    package { $apache::params::php_extensions:
        ensure => $phpensure
    }

    # Apache user
    user { $apache::params::user:
        ensure  => $apache::ensure,
        require => Package['apache2'],
        shell   => '/bin/sh',
    }
    # Apache group
    group { $apache::params::group:
        ensure  => $apache::ensure,
        require => Package['apache2']
    }

    # Graceful restart of the apache server
    exec { $apache::params::gracefulrestart:
        path        => '/usr/bin:/usr/sbin/:/bin:/sbin',
        require     => Package['apache2'],
        onlyif      => $apache::params::configtest,
        refreshonly => true,
    }

    # Specific SSL part
    apache::module {'ssl':
        ensure => $sslensure,
        notify => Exec[$apache::params::gracefulrestart],
    }
    if ($apache::use_ssl) {
        include 'openssl'
    }

    # Activate the rewrite module for automatic SSL redirection
    apache::module { 'rewrite':
        ensure => $sslensure,
        notify => Exec[$apache::params::gracefulrestart],
    }
    apache::module { 'headers':
        ensure => $sslensure,
        notify => Exec[$apache::params::gracefulrestart],
    }

    if $apache::ensure == 'present' {

        # main root configuration dir (/etc/apache2 on Debian systems)
        file { $apache::params::configdir:
            ensure  => 'directory',
            owner   => $apache::params::configdir_owner,
            group   => $apache::params::configdir_group,
            mode    => $apache::params::configdir_mode,
            require => Package['apache2'],
        }

        # Other configuration files directory (conf.d)
        file { $apache::params::otherconfigdir:
            ensure  => 'directory',
            owner   => $apache::params::configdir_owner,
            group   => $apache::params::configdir_group,
            mode    => $apache::params::configdir_mode,
            require => [
                        File[$apache::params::configdir],
                        Package['apache2']
                        ],
        }

        concat { $apache::params::ports_file:
            warn    => false,
            owner   => $apache::params::configdir_owner,
            group   => $apache::params::configdir_group,
            mode    => $apache::params::configfile_mode,
            require => Package['apache2'],
            notify  => Exec[$apache::params::gracefulrestart],
        }

        $ports_file_ensure_default_entry = $apache::enable_default_listen ? {
            true    => $apache::ensure,
            default => $apache::enable_default_listen ? {
                false   => 'absent',
                default => 'present'
            }
        }

        concat::fragment { "${apache::params::ports_file}_header":
            ensure  => $apache::ensure,
            target  => $apache::params::ports_file,
            order   => 1,
            content => template('apache/ports.conf_header.erb'),
            notify  => Exec[$apache::params::gracefulrestart],
        }

        concat::fragment { $apache::params::ports_file_default_entry:
            ensure  => $ports_file_ensure_default_entry,
            target  => $apache::params::ports_file,
            order   => 10,
            content => template("apache/${apache::params::ports_template}"),
            notify  => Exec[$apache::params::gracefulrestart],
        }



        # Where to put www data
        file { $apache::params::wwwdir:
            ensure  => 'directory',
            owner   => $apache::params::wwwdir_owner,
            group   => $apache::params::wwwdir_group,
            mode    => $apache::params::wwwdir_mode,
            require => Package['apache2'],
        }

        # disable default index.html
        file {"${apache::params::wwwdir}/index.html":
            ensure => absent,
        }

        # Create the directory to host the default index.html
        file {"${apache::params::wwwdir}/default-html":
            ensure  => 'directory',
            owner   => $apache::params::user,
            group   => $apache::params::group,
            mode    => $apache::params::wwwdir_mode,
            require => File[$apache::params::wwwdir],
        }

        $indexfile = $apache::use_php ? {
            true    => 'index.php',
            default => 'index.html'
        }

        $indexfile_content = $apache::use_php ? {
            true    => '<?php phpinfo(); ?>',
            default => ' '
        }

        # ... and populate it with the default index.{html|php}
        file {"${apache::params::wwwdir}/default-html/${indexfile}":
            ensure  => $apache::ensure,
            owner   => $apache::params::user,
            group   => $apache::params::group,
            mode    => $apache::params::configfile_mode,
            content => "<html><body><h1>It works! (default-html)</h1>${indexfile_content}</body></html>\n",
            require => File["${apache::params::wwwdir}/default-html"],
            notify  => Exec[$apache::params::gracefulrestart],
        }

        # CGI bin directory
        file { $apache::params::cgidir:
            ensure  => 'directory',
            owner   => $apache::params::cgidir_owner,
            group   => $apache::params::cgidir_group,
            mode    => $apache::params::cgidir_mode,
            require => Package['apache2'],
        }

        # Apache Logs directory
        file { $apache::params::logdir:
            ensure  => 'directory',
            owner   => $apache::params::logdir_owner,
            group   => $apache::params::logdir_group,
            mode    => $apache::params::logdir_mode,
            require => Package['apache2'],
        }

        # Apache virtual host dir (both available and enabled)
        file { [
                $apache::params::vhost_availabledir,
                $apache::params::vhost_enableddir,
                $apache::params::mods_availabledir,
                $apache::params::mods_enableddir
                ]:
                    ensure  => 'directory',
                    owner   => $apache::params::configdir_owner,
                    group   => $apache::params::configdir_group,
                    mode    => $apache::params::configdir_mode,
                    seltype => $apache::params::configdir_seltype,
                    notify  => Exec[$apache::params::gracefulrestart],
                    require => Package['apache2'],
        }

        # The default virtual host file
        file { "${apache::params::vhost_availabledir}/${apache::params::default_vhost_file}${apache::params::vhost_extension}":
            ensure  => $apache::ensure,
            owner   => $apache::params::configdir_owner,
            group   => $apache::params::configdir_group,
            mode    => $apache::params::configfile_mode,
            seltype => $apache::params::configdir_seltype,
            content => template("apache/${apache::params::vhost_default}"),
            require => File[$apache::params::vhost_availabledir],
        }


        # TODO: remove default-ssl?

        service { 'apache2':
            ensure     => running,
            name       => $apache::params::servicename,
            enable     => true,
            hasrestart => $apache::params::hasrestart,
            pattern    => $apache::params::processname,
            hasstatus  => $apache::params::hasstatus,
            require    => Package['apache2'],
        }

    }
    else
    {
        # Here $apache::ensure is 'absent'

    }

}

