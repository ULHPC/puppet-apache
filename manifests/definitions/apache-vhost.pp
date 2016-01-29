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
#   Default: 'present'
#
# [*port*]
#  The port to configure the host on (for regular http access).
#  Default: 80
#
# [*htdocs_target*]
#  You may specialize a link as htdocs (to /var/share/mediawiki for instance).
#  Then /var/www/<vhostname>/htdocs will be a symlink to <htdocs_target> (by
#  default, it is a regular directory).
#
# [*documentroot*]
#  Specifies the value of the 'DocumentRoot' directive.
#  Default: /var/www/<vhostname>/htdocs
#
# [*content*]
#  Specify the contents of the  vhost config as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*source*]
#  Copy a file as the content of the vhost config.  Uses checksum to determine when a file
#  should be copied. Valid values are either fully qualified paths to files, or
#  URIs. Currently supported URI types are puppet and file.
#
# [*serveradmin*]
#  The vhost admin (i.e. its mail address).
#  Default: 'webmaster@localhost'
#
# [*use_ssl*]
#  The $use_ssl option is set true or false to enable SSL for this Virtual Host.
#  If set to true, the default vhost for http access will be configured for an
#  automatic redirection to the https access.
#  Also, unless the various sources of the certificate etc. has been provided, a
#  self-signed certificate will be created.
#  In all cases, see all the $ssl* parameters
#  Default: ${apache::use_ssl}
#
# [*redirect_ssl*]
#  Redirect automatically to https.
#  Default: false
#
# [*priority*]
#  Set the priority of the site (typically between 000 and 990).
#  Default: 010
#
# [*options*]
#  The option for the Directory directive.
#
# [*allow_override*]
#  Value of the AllowOverride directive, to authorize redefinition of specific
#  groups of directives in htaccess.
#
# [*passenger_app_root*]
#  Indicate the root of your Ruby On Rails application. You MUST include
#  passenger module, and htdocs_target must point to the public directory of
#  the application.
#
# [*allow_from*]
#  List of IPs to authorize the access to the Vhosts
#  Default: [] (empty list) i.e. full access
#
# [*aliases*]
#  List of ServerAliases
#
# [*enable_default*]
#  Whether or not to activate the default website (the one in
#  /var/www/default-html).
#  Default: true
#
# [*enable_cgi*]
#  Whether or not to activate & create the cgi-bin directory
#  Default: true
#
# [*testing_mode]
#  This puts a sample 'index.html' in the documentroot to check that the virtual
#  is indeed activated. This mode is NOT COMPATIBLE with the htdocs_target
#  directive.
#  Default: false
#
# [*sslport*]
#  Only meaningfull if use_ssl = true
#  The port to configure for https access
#  Default: 443
#
# [*ssl_certfile_source*]
#  Only meaningfull if use_ssl = true
#  optional source URL of the certificate, if the default self-signed generated
#  one doesn't suit.
#  If this parameter IS NOT specified, then it is assumed one expect the
#  generation of a self-signed certificate.
#
# [*ssl_keyfile_source*]
#  Only meaningfull if use_ssl = true and ssl_certfile_source != ''
#   optional source URL of the private key.
#
# [*ssl_cacertfile_source*]
#   optional source URL of the CA certificate.
#
# [*ssl_certchainfile_source*]
#   optional source URL of the CA chain certificate.
#
# [*ssl_crlfile_source*]
#   optional source URL of the CRL.
#
# [*ssl_cert_country*]
#   Self-signed certificate countryName
#   Default: 'LU'
#
# [*ssl_cert_state*]
#   Self-signed certificate stateOrProvinceName
#
# [*ssl_cert_locality*]
#   Self-signed certificate localityName
#   Default: 'Luxembourg'
#
# [*ssl_cert_organisation*]
#   Self-signed certificate organizationName
#   Default: 'University of Luxembourg'
#
# [*ssl_cert_organisational_unit*]
#   Self-signed certificate organizationalUnitName
#   Default: 'Computer Science and Communication (CSC) Research Unit'
#
# [*ssl_cert_days*]
#   Self-signed certificate validity
#   Default: 10 years
#
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
#   To activate an SSL vhost:
#
#    apache::vhost { 'puppet-test':
#        ensure  => 'present',
#        use_ssl => true,
#        testing_mode => true,
#    }

#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::vhost(
    $content            = '',
    $source             = '',
    $serveradmin        = 'webmaster@localhost',
    $port               = '80',
    $documentroot       = '',
    $ensure             = 'present',
    $use_ssl            = $apache::use_ssl,
    $redirect_ssl       = $apache::redirect_ssl,
    $priority           = '010',
    $options            = 'Indexes FollowSymLinks MultiViews',
    $allow_override     = $apache::params::allow_override,
    $allow_from         = [],
    $passenger_app_root = '',
    $htdocs_target      = '',
    $vhost_name         = ['*'],
    $aliases            = [],
    $enable_default     = true,
    $enable_cgi         = true,
    $testing_mode       = false,
    # Below are SSL-only parameters, only relevant if $use_ssl = true
    $sslport                  = '443',
    $ssl_certfile_source      = '',
    $ssl_keyfile_source       = '',
    $ssl_cacertfile_source    = '',
    $ssl_certchainfile_source = '',
    $ssl_crlfile_source       = '',
    $ssl_cacertdir            = '',
    $ssl_crldir               = '',
    $ssl_cert_country         = 'LU',
    $ssl_cert_state           = false,
    $ssl_cert_locality        = 'Luxembourg',
    $ssl_cert_organisation    = 'University of Luxembourg',
    $ssl_cert_organisational_unit = 'Computer Science and Communication (CSC) Research Unit',
    $ssl_cert_days            = 3650
)
{

    include apache::params

    # $name is provided by define invocation and is should be set to the content
    # of the ServerName directive
    $servername = $name

    # Variables setup
    $real_serveradmin = $serveradmin ? {
        ''      => 'webmaster@localhost',
        default => "${serveradmin}"
    }
    $real_documentroot = $documentroot ? {
        ''      => "${apache::params::wwwdir}/${servername}/htdocs",
        default => "${documentroot}"
    }

    if ($passenger_app_root != '' and ! defined(Class['passenger'])) {
        fail("Class passenger is not instencied")
    }

    if ($use_ssl == true and $apache::use_ssl == false)
    {
        fail("apache::vhost::use_ssl == true requires apache::use_ssl == true")
    }

    # Specific SSL variables
    if ($use_ssl) {
        include openssl::params

        $ssl_certfile = "${apache::params::wwwdir}/${servername}/certificates/${servername}${openssl::params::cert_filename_suffix}"
        $ssl_keyfile  = "${apache::params::wwwdir}/${servername}/certificates/${servername}${openssl::params::key_filename_suffix}"
        $ssl_cacertfile = $ssl_cacertfile_source ? {
            ''      => "${openssl::params::default_ssl_cacert}",
            default => "${apache::params::wwwdir}/${servername}/certificates/cacert.pem"
        }
        # Server Certificate Chain
        $ssl_certchainfile = $ssl_certchainfile_source ? {
            ''      => '',
            default => "${apache::params::wwwdir}/${servername}/certificates/cacertchain.crt"
        }
        # Certificate Revocation Lists (CRL)
        $ssl_crlfile = $ssl_crlfile_source ? {
            ''      => '',
            default => "${apache::params::wwwdir}/${servername}/certificates/ca-bundle.crl"
        }
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
    }
    else {
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

            include concat::setup

            concat { "${apache::params::vhost_availabledir}/${priority}-${servername}":
                warn    => false,
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                #seltype => "${apache::params::configdir_seltype}",
                require => Package['apache2'],
                notify  => Exec["${apache::params::gracefulrestart}"],
            }

            if ("${content}" != '' or "${source}" != '') {
                concat::fragment { "${priority}-${servername}_content":
                    target  => "${apache::params::vhost_availabledir}/${priority}-${servername}",
                    content => "${content}",
                    source  => "${source}",
                    ensure  => "${ensure}",
                    order   => 01,
                }
            }
            else
            {
                # Header of the file
                concat::fragment { "${priority}-${servername}_header":
                    target  => "${apache::params::vhost_availabledir}/${priority}-${servername}",
                    content => template('apache/vhost_header.erb'),
                    ensure  => "${ensure}",
                    order   => 01,
                }

                # Footer of the file
                concat::fragment { "${priority}-${servername}_footer":
                    target  => "${apache::params::vhost_availabledir}/${priority}-${servername}",
                    content => template('apache/vhost_footer.erb'),
                    ensure  => "${ensure}",
                    order   => 99,
                }

                if ($use_ssl) {
                    concat { "${apache::params::vhost_availabledir}/${priority}-${servername}-ssl":
                        warn    => false,
                        owner   => 'root',
                        group   => 'root',
                        mode    => '0644',
                        #seltype => "${apache::params::configdir_seltype}",
                        require => Package['apache2'],
                        notify  => Exec["${apache::params::gracefulrestart}"],
                    }

                    # Header of the file
                    concat::fragment { "${priority}-${servername}-ssl_header":
                        target  => "${apache::params::vhost_availabledir}/${priority}-${servername}-ssl",
                        content => template('apache/vhost-ssl_header.erb'),
                        ensure  => "${ensure}",
                        order   => 01,
                    }

                    # Footer of the file
                    concat::fragment { "${priority}-${servername}-ssl_footer":
                        target  => "${apache::params::vhost_availabledir}/${priority}-${servername}-ssl",
                        content => template('apache/vhost-ssl_footer.erb'),
                        ensure  => "${ensure}",
                        order   => 99,
                    }
                }
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

            $htdocs_type = $htdocs_target ? {
                ''      => 'directory',
                default => 'link',
            }
            file { "${apache::params::wwwdir}/${servername}/htdocs" :
                ensure  => "${htdocs_type}",
            #   owner   => "${apache::params::user}",
                group   => "${apache::params::group}",
                mode    => "${apache::params::htdocs_mode}",
                seltype => "${apache::params::configdir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }
            if ($htdocs_target != '') {
                File["${apache::params::wwwdir}/${servername}/htdocs"] {
                    target => "${htdocs_target}"
                }
            }

            # When in testing mode, put a 'fake' index.{html|php} in htdocs/ to be able
            # to check that everything works as expected.
            if $testing_mode {
                if ($htdocs_target != '') {
                    fail("Cannot be in testing mode when htdocs_target is activated")
                }
                $indexfile = $apache::use_php ? {
                    true    => 'index.php',
                    default => 'index.html'
                }
                $indexfile_content = $apache::use_php ? {
                    true    => "<?php phpinfo(); ?>",
                    default => " "
                }

                file { "${apache::params::wwwdir}/${servername}/htdocs/${indexfile}":
                    ensure  => "${apache::ensure}",
                    owner   => "${apache::params::user}",
                    group   => "${apache::params::group}",
                    mode    => "${apache::params::configfile_mode}",
                    content => inline_template("<html><body><h1><%= servername %> works!</h1>${indexfile_content}</body></html>\n"),
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

            # config data
            file { "${apache::params::wwwdir}/${servername}/config":
                ensure  => 'directory',
                owner   => "${apache::params::user}",
                group   => "${apache::params::group}",
                mode    => "${apache::params::wwwdir_mode}",
                seltype => "${apache::params::privatedir_seltype}",
                require => File["${apache::params::wwwdir}/${servername}"],
            }
            file { "${apache::params::wwwdir}/${servername}/config/vhost_${servername}":
                ensure  => 'link',
                target  => "${apache::params::vhost_availabledir}/${priority}-${servername}",
                require => File["${apache::params::wwwdir}/${servername}/config"]
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

            # place holder for SSL certificates
            if ($use_ssl) {
                file { "${apache::params::wwwdir}/${servername}/config/vhost_${servername}-ssl":
                    ensure  => 'link',
                    target  => "${apache::params::vhost_availabledir}/${priority}-${servername}-ssl",
                    require => File["${apache::params::wwwdir}/${servername}/config"]
                }


                file { "${apache::params::wwwdir}/${servername}/certificates":
                    ensure  => 'directory',
                    owner   => "${apache::params::user}",
                    group   => "${apache::params::group}",
                    mode    => "${apache::params::wwwdir_mode}",
                    #seltype => "${apache::params::privatedir_seltype}",
                    require => File["${apache::params::wwwdir}/${servername}"],
                }

                # Setup the certificates
                if ($ssl_certfile_source != '') {
                    # The optional source URL of the certificate has been passed
                    file { "$ssl_certfile":
                        ensure  => 'file',
                        owner   => "${apache::params::user}",
                        group   => "${apache::params::group}",
                        mode    => '0644',
                        seltype => "${apache::params::certificates_seltype}",
                        source  => "${ssl_certfile_source}",
                        require => File["${apache::params::wwwdir}/${servername}/certificates"],
                    }
                    # The associated keyfile should have been passed too...
                    if ($ssl_keyfile_source != '') {
                        file { "$ssl_keyfile":
                            ensure  => 'file',
                            owner   => "${apache::params::user}",
                            group   => "${apache::params::group}",
                            mode    => '0600',
                            seltype => "${apache::params::certificates_seltype}",
                            source  => "${ssl_keyfile_source}",
                            require => File["${apache::params::wwwdir}/${servername}/certificates"],
                        }
                    }
                    else {
                        # Extra protection
                        fail("the source of the key file of the certificate should have been passed")
                    }
                    # ... and also the CA certificate
                    if ($ssl_cacertfile_source != '') {
                        file { "$ssl_cacertfile":
                            ensure  => 'file',
                            owner   => "${apache::params::user}",
                            group   => "${apache::params::group}",
                            mode    => '0600',
                            seltype => "${apache::params::certificates_seltype}",
                            source  => "${ssl_cacertfile_source}",
                            require => File["${apache::params::wwwdir}/${servername}/certificates"],
                        }
                    }
                    # or eventually the certification chain
                    if ($ssl_certchainfile_source != '') {
                        file { "$ssl_certchainfile":
                            ensure  => 'file',
                            owner   => "${apache::params::user}",
                            group   => "${apache::params::group}",
                            mode    => '0600',
                            seltype => "${apache::params::certificates_seltype}",
                            source  => "${ssl_certchainfile_source}",
                            require => File["${apache::params::wwwdir}/${servername}/certificates"],
                        }
                    }
                }
                else {
                    # here $ssl_certfile_source = '' i.e. one expects Puppet to
                    # generate a self-signed certificate for the site
                    openssl::x509::generate { "${servername}":
                        email        => "${serveradmin}",
                        commonname   => "${fqdn}",
                        ensure       => "${ensure}",
                        country      => "${ssl_cert_country}",
                        state        => "${ssl_cert_state}",
                        locality     => "${ssl_cert_locality}",
                        organization => "${ssl_cert_organisation}",
                        organizational_unit => "${ssl_cert_organisational_unit}",
                        days         => "${ssl_cert_days}",
                        basedir      => "${apache::params::wwwdir}/${servername}/certificates",
                        owner        => "${apache::params::user}",
                        group        => "${apache::params::group}",
                        self_signed  => true,
                        require      => File["${apache::params::wwwdir}/${servername}/certificates"]
                    }
                }

                if ($ssl_crlfile_source != '') {
                    file { "$ssl_crlfile":
                        ensure => 'file',
                        owner  => "${apache::params::user}",
                        group  => "${apache::params::group}",
                        mode   => '0600',
                        source => "${ssl_crlfile_source}",
                        require => File["${apache::params::wwwdir}/${servername}/certificates"],
                    }
                }


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
            if ($use_ssl) {
                exec{ "enable '${servername}' SSL vhost":
                    command => "${apache::params::a2ensite} ${priority}-${servername}-ssl",
                    path => "/usr/bin:/usr/sbin/:/bin:/sbin",
                    unless  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}-ssl'",
                    require => [
                                Package['apache2'],
                                File["${apache::params::vhost_availabledir}/${priority}-${servername}-ssl"],
                                File["${apache::params::wwwdir}/${servername}/htdocs"],
                                File["${apache::params::wwwdir}/${servername}/cgi-bin"],
                                File["${apache::params::wwwdir}/${servername}/logs"],
                                File["${apache::params::wwwdir}/${servername}/private"],
                                File["${apache::params::wwwdir}/${servername}/certificates"],
                                ],
                    notify  => Exec["${apache::params::gracefulrestart}"],
                }
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
                onlyif  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}'",
            }
            if ($use_ssl) {
                file {
                    [
                     "${apache::params::vhost_enableddir}/${priority}-${servername}-ssl",
                     "${apache::params::vhost_availabledir}/${priority}-${servername}-ssl"
                     ]:
                         ensure  => 'absent',
                         force   => true,
                         require => Exec["disable SSL vhost ${servername}"]
                }
                exec { "disable SSL vhost ${servername}":
                    command => "${apache::params::a2dissite} ${priority}-${servername}-ssl",
                    notify  => Exec["${apache::params::gracefulrestart}"],
                    require => Package['apache2'],
                    onlyif  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}-ssl'",
                }

            }



        }

        disabled: {
            exec { "disable vhost ${servername}":
                command => "${apache::params::a2dissite} ${priority}-${servername}",
                notify  => Exec["${apache::params::gracefulrestart}"],
                require => Package['apache2'],
                onlyif  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}'",
            }
            file{ "${apache::params::vhost_enableddir}/${priority}-${servername}":
                ensure  => absent,
                require => Exec["disable vhost ${servername}"]
            }

            if ($use_ssl) {
                exec { "disable SSL vhost ${servername}":
                    command => "${apache::params::a2dissite} ${priority}-${servername}-ssl",
                    notify  => Exec["${apache::params::gracefulrestart}"],
                    require => Package['apache2'],
                    onlyif  => "test -L '${apache::params::vhost_enableddir}/${priority}-${servername}-ssl'",
                }
                file{ "${apache::params::vhost_enableddir}/${priority}-${servername}-ssl":
                    ensure  => absent,
                    require => Exec["disable SSL vhost ${servername}"]
                }
            }

        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }


}


