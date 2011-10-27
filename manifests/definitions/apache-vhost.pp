# File::      <tt>apache-vhost.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
# ------------------------------------------------------------------------------
# = Defines: apache::vhost
#
# This definition installs Apache Virtual Hosts i.e. a given site to be managed by Apache
#
# == Pre-requisites
#
# * The class 'apache' should have been instanciated
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: it will remove the associated
#   directory in /var/www) or 'disabled'
#
# [*port*]
#  The port to configure the host on
#
# [*documentroot*]
#  Specifies the value of the 'DocumentRoot' directive. Default to
#  /var/www/<vhostname>/htdocs
#
# [*serveradmin*]
#  The vhost admin (i.e. its mail address), default to 'webmaster@localhost'
#
# [*use_ssl*]
#  The $use_ssl option is set true or false to enable SSL for this Virtual Host
#  NOT YET IMPLEMENTED
#
# [*priority*]
#  Set the priority of the site (typically between 000 and 990), default to 010
#
# [*options*]
#  the option for the Directory directive.
#
# [*aliases*]
#  List of ServerAliases
#
# [*enable_default*]
#  Whether or not to activate the default website (the one in
#  /var/www/default-html). Default to 'true'
#
# [*testing_mode]
#  This puts a sample 'inde.html' in the documentroot to check that the virtual
#  is indeed activated.
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#  apache::vhost { 'localtest.domain.com':
#        ensure       => 'present',
#        testing_mode => true,          
#   }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::vhost(
    $serveradmin    = 'webmaster@localhost',
    $port           = '80',
    $documentroot   = '',
    $ensure         = 'present',
    $use_ssl        = $apache::use_ssl,
    $priority       = '010',
    $options        = 'Indexes FollowSymLinks MultiViews',
    $vhost_name     = '*',
    $aliases        = [],
    $enable_default = true,
    $testing_mode   = false,
    $ssl_certfile   = '',
    $ssl_keyfile    = '',
    $ssl_certchainfile = '',
    $ssl_cacertdir  = '',
    $ssl_cacertfile = '',
    $ssl_crldir     = '',
    $ssl_crlfile    = '',    
)
{

    include apache::params

    # $name is provided by define invocation and is should be set to the content
    # of the ServerName directive
    $servername = $name

    $real_serveradmin = $serveradmin ? {
        ''      => 'webmaster@localhost',
        default => "${serveradmin}"
    }

    $real_documentroot = $documentroot ? {
        ''      => "${apache::params::wwwdir}/${servername}/htdocs",
        default => "${documentroot}"
    }



    # check if default virtual host is enabled
    if $enable_default {
        exec { "check if default virtual host is enabled for $servername":
            command => "${apache::params::a2ensite} default",
            path => "/usr/bin:/usr/sbin/:/bin:/sbin",
            unless  => "test -L '${apache::params::vhost_enableddir}/000-default'",
            require => Package['apache2'],
            notify  => Exec["${apache::params::gracefulrestart}"],
        }
    } else {
        exec { "disable default virtual host $servername":
            command => "${apache::params::a2dissite} default",
            path => "/usr/bin:/usr/sbin/:/bin:/sbin",
            onlyif  => "test -L '${apache::params::vhost_enableddir}/000-default'",
            require => Package['apache2'],
            notify  => Exec["${apache::params::gracefulrestart}"],
        }    
    }

    case $ensure {
        present: {

            # create the config file for the vhost
            file { "${apache::params::vhost_availabledir}/${priority}-${servername}":
                content => template('apache/vhost.erb'),
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                seltype => "${apache::params::configdir_seltype}",
                require => Package['apache2'],
                notify  => Exec["${apache::params::gracefulrestart}"],
            }

            # create the directory to host the www files
            file {"${apache::params::wwwdir}/${servername}":
                ensure  => 'directory',
                owner   => "${apache::params::wwwdir_owner}",
                group   => "${apache::params::wwwdir_group}",
                mode    => "${apache::params::wwwdir_mode}",
                seltype => "${apache::params::configdir_seltype}",
                require => File["${apache::params::wwwdir}"],
            }

            file { "${apache::params::wwwdir}/${servername}/htdocs" :
                ensure  => 'directory',
                owner   => "${apache::params::user}",
                group   => "${apache::params::group}",
                mode    => "${apache::params::wwwdir_mode}",
                seltype => "${apache::params::configdir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }

            # When in testing mode, put a 'fake' index.html in htdocs/ to be able
            # to check that everything works as expected.
            if $testing_mode {
                file { "${apache::params::wwwdir}/${servername}/htdocs/index.html":
                    ensure  => "${apache::ensure}",
                    owner   => "${apache::params::user}",
                    group   => "${apache::params::group}",
                    mode    => "${apache::params::configfile_mode}",
                    content => inline_template("<html><body><h1><%= servername %> works!</h1></body></html>\n"),
                    require => File["${apache::params::wwwdir}/default-html"],
                    notify  => Exec["${apache::params::gracefulrestart}"],

                }

            }

            # place holder for CGI scripts
            file { "${apache::params::wwwdir}/${servername}/cgi-bin":
                ensure  => 'directory',
                owner   => "${apache::params::user}",
                group   => "${apache::params::group}",
                mode    => "${apache::params::wwwdir_mode}",
                seltype => "${apache::params::cgidir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }

            # place holder for logs
            file { "${apache::params::wwwdir}/${servername}/logs":
                ensure  => 'directory',
                owner   => "${apache::params::logdir_owner}",
                group   => "${apache::params::logdir_group}",
                mode    => "${apache::params::logdir_mode}",
                seltype => "${apache::params::logdir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }
            # Create the symbolic links to the real log files
            file { "${apache::params::wwwdir}/${servername}/logs/error.log":
                ensure  => 'link',
                target  => "${apache::params::logdir}/${servername}_error.log",
                require => File["${apache::params::logdir}"]
            }
            file { "${apache::params::wwwdir}/${servername}/logs/access.log":
                ensure => 'link',
                target => "${apache::params::logdir}/${servername}_access.log",
                require => File["${apache::params::logdir}"]
            }

            # Private data
            file { "${apache::params::wwwdir}/${servername}/private":
                ensure  => 'directory',
                owner   => "${apache::params::user}",
                group   => "${apache::params::group}",
                mode    => "${apache::params::wwwdir_mode}",
                seltype => "${apache::params::privatedir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }

            # README file
            file { "${apache::params::wwwdir}/${servername}/README":
                content => template('apache/README_vhost.erb'),
                ensure  => 'present',
                owner   => "${apache::params::wwwdir_owner}",
                group   => "${apache::params::wwwdir_group}",
                mode    => '0644',
                require => File["${apache::params::wwwdir}/${servername}"],
            }

            # Now enable the virtual host
            exec{ "enable '${servername}' vhost":
                command => "${apache::params::a2ensite} ${priority}-${servername}",
                path => "/usr/bin:/usr/sbin/:/bin:/sbin",
                unless  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}'",
                require => [
                            Package['apache2'],
                            File["${apache::params::vhost_availabledir}/${priority}-${servername}"],
                            File["${apache::params::wwwdir}/${servername}/htdocs"],
                            File["${apache::params::wwwdir}/${servername}/cgi-bin"],
                            File["${apache::params::wwwdir}/${servername}/logs"],
                            File["${apache::params::wwwdir}/${servername}/private"],
                            ],
                notify  => Exec["${apache::params::gracefulrestart}"],

            }


        }

        absent: {
            file {
                [
                 "${apache::params::vhost_enableddir}/${priority}-${servername}",
                 "${apache::params::vhost_availabledir}/${priority}-${servername}",
                 "${apache::params::wwwdir}/${servername}",                 
                 ]:
                     ensure  => 'absent',
                     recurse => true,
                     force   => true,
                     require => Exec["disable vhost ${servername}"]
            }

            exec { "disable vhost ${servername}":
                command => "${apache::params::a2dissite} ${priority}-${servername}",
                notify  => Exec["${apache::params::gracefulrestart}"],
                require => Package['apache2'],
                onlyif => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
                && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
            }



        }

        disabled: {
            exec { "disable vhost ${servername}":
                command => "${apache::params::a2dissite} ${priority}-${servername}",
                notify  => Exec["${apache::params::gracefulrestart}"],
                require => Package['apache2'],
                onlyif => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
                && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
            }
            file{ "${apache::params::vhost_enableddir}/${priority}-${servername}": 
                ensure  => absent,
                require => Exec["disable vhost ${servername}"]
            }
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }


}


