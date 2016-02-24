# File::      <tt>vhost/directory.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Defines: apache::vhost::directory
#
# This definition configure a specific directory for an apache vhost
#
# == Pre-requisites
#
# * The class 'apache' should have been instanciated
# * 'apache::vhost' should have been defined for whatever you put in the vhost directive
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: it will remove the associated
#   directory in /var/www) or 'disabled'
#   Default: 'present'
#
# [*vhost*]
#   the name of the vhost on which this directory applies.
#
#
# [*content*]
#  Specify the contents of the Directory directive as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*source*]
#  Copy a file as the content of the Directory directive.
#  Uses checksum to determine when a file
#  should be copied. Valid values are either fully qualified paths to files, or
#  URIs. Currently supported URI types are puppet and file.
#
# [*diralias*]
#  The Alias directive. Note that the precise dir
#  Example: alias => "/phpmyadmin/" will result in the configuration
#          Alias /phpmyadmin/ <name>
#
# [*comment*]
#  An optional comment to add on top of the directory
#
# [*order*]
#  Set the order of the directory definition (typically between 10 and 90).
#  Default: 40
#
# [*options*]
#  the option for the Directory directive.
#  Default: 'Indexes FollowSymLinks MultiViews'
#
# [*allow_from*]
# List of IPs to authorize the access to the Vhosts
# Default: [] (empty list) i.e. full access
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#    apache::vhost { 'localtest.domain.com':
#         ensure   => 'present',
#         use_ssl  => true,
#         use_php  => true,
#    }
#
#    apache::vhost::directory { '/var/www/phpmyadmin/':
#         vhost      => 'localtest.domain.com'
#         ensure     => 'present',
#         options    => 'Indexes FollowSymLinks MultiViews',
#         diralias   => '/phpmyadmin/',
#         allow_from => [ '192.168.1.1', '10.1.2.3' ],
#         comment    => "PhpMyAdmin"
#    }
#
#    The above setting will result in the following configuration of the
#    'localtest.domain.com' vhost:
#
#    #### PhpMyAdmin
#    Alias /phpmyadmin/ /var/www/phpmyadmin/
#    <Directory /var/www/phpmyadmin/>
#             Options Indexes FollowSymLinks MultiViews
#             # Restrict phpmyadmin access to just my worksation
#             Order Deny,Allow
#             Deny from all
#             # /!\ List here the authorized IP for the access to phpmyadmin
#             Allow from 192.168.1.1
#             Allow from 10.1.2.3
#     </Directory>
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::vhost::directory(
    $vhost,
    $ensure     = 'present',
    $content    = '',
    $source     = '',
    $order      = '40',
    $options    = 'Indexes FollowSymLinks MultiViews',
    $allow_from = [],
    $diralias   = '',
    $comment    = ''
)
{

    include apache::params

    # $name is provided by define invocation and is should be set to the
    # directory path
    $dirname = $name

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache::vhost::directory 'ensure' parameter must be set to either 'absent', or 'present'")
    }
    if ($apache::ensure != $ensure) {
        if ($apache::ensure != 'present') {
            fail("Cannot configure the directory '${dirname}' as apache::ensure is NOT set to present (but ${apache::ensure})")
        }
    }

    if ( ! defined(Apache::Vhost[$vhost])) {
        crit("The Apache virtual host '${vhost}' has not been specified")
    }
    # TODO: check that the ensure parameter of Apache::Vhost["${vhost}"] is set
    # to present

    # if content is passed, use that, else if source is passed use that
    $real_content = $content ? {
        '' => $source ? {
            ''      => template('apache/vhost-directory.erb'),
            default => ''
        },
        default => $content
    }
    $real_source = $source ? {
        '' => '',
        default => $content ? {
            ''      => $source,
            default => ''
        }
    }

    # TODO: access the value of Apache::Vhost["${vhost}"][priority]
    # Problem: I don't know how to deal with it.
    $priority = '010'
    $vhost_file = $apache::use_ssl ? {
        true    => "${apache::params::vhost_availabledir}/${priority}-${vhost}-ssl${apache::params::vhost_extension}",
        default => "${apache::params::vhost_availabledir}/${priority}-${vhost}${apache::params::vhost_extension}"
    }

    concat::fragment { "apache_vhost_${vhost}_directory_${dirname}":
        ensure  => $ensure,
        target  => $vhost_file,
        order   => $order,
        content => $real_content,
        source  => $real_source,
        notify  => Exec[$apache::params::gracefulrestart],
    }
}


