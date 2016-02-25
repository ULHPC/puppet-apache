# File::      <tt>vhost/reverse_proxy.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Defines: apache::vhost::reverse_proxy
#
# This definition map a remote server in the local url space for an apache vhost
#
#  Note that the name of the definition will be the source source path. HTTP
#  requests on this path will be proxied to the target_url.
#  Example: "/ganglia/" will result in the configuration
#          ProxyPass        /ganglia/ <target_url>
#          ProxyPassReverse /ganglia/ <target_url>
#
# == Pre-requisites
#
# * The class 'apache' should have been instanciated
# * 'apache::vhost' should have been defined for whatever you put in the vhost directive
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' or 'disabled'
#   Default: 'present'
#
# [*vhost*]
#   the name of the vhost on which this definition applies.
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
# [*target_url*]
#  Target URL, url on which will all requests will be proxied.
#  Example: target_url => "http://myhost.my.org" will result in the configuration
#          ProxyPass        <source_path> http://myhost.my.org
#          ProxyPassReverse <source_path> http://myhost.my.org
#
# [*comment*]
#  An optional comment to add on top of the directory
#
# [*order*]
#  Set the order of the reverse proxy definition (typically between 10 and 90).
#  Default: 50
#
# [*allow_from*]
# List of IPs to authorize the access to the path
# Default: [] (empty list) i.e. full access
#
# [*headers*]
# Set the headers when querying the proxied service
# Default: {} (empty hash)
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
#    apache::vhost::reverse_proxy { '/ganglia/':
#         vhost       => 'localtest.domain.com',
#         ensure      => 'present',
#         target_url  => 'http://myhost.my.org/ganglia',
#         allow_from  => [ '192.168.1.1', '10.1.2.3' ],
#         comment     => "Ganglia",
#         headers     => {'X-Test' => 'Value 1', 'X-Test2' => 'Value 2'}
#    }
#
#    The above setting will result in the following configuration of the
#    'localtest.domain.com' vhost:
#
#    #### Ganglia
#    ProxyPass        /ganglia/ http://myhost.my.org
#    ProxyPassReverse /ganglia/ http://myhost.my.org
#    <Proxy http//localtest.domain.com/ganglia/*>
#             Order Deny,Allow
#             Deny from all
#             # /!\ List here the authorized IP for the access to phpmyadmin
#             Allow from 192.168.1.1
#             Allow from 10.1.2.3
#     </Proxy>
#     <Location /ganglia/>
#             RequestHeader set X-Test 'Value 1'
#             RequestHeader set X-Test2 'Value 2'
#     </Location>
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::vhost::reverse_proxy(
    $vhost,
    $ensure     = 'present',
    $content    = undef,
    $source     = undef,
    $target_url = '',
    $order      = '50',
    $allow_from = [],
    $comment    = '',
    $headers    = {}
)
{

    include apache::params

    # $name is provided by define invocation and is should be set to the
    # directory path
    $source_path = $name

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache::vhost::directory 'ensure' parameter must be set to either 'absent', or 'present'")
    }
    if ($apache::ensure != $ensure) {
        if ($apache::ensure != 'present') {
            fail("Cannot configure the directory '${apache::vhost::directory::dirname}' as apache::ensure is NOT set to present (but ${apache::ensure})")
        }
    }

    if ( ! defined(Apache::Vhost[$vhost])) {
        crit("The Apache virtual host '${vhost}' has not been specified")
    }
    # TODO: check that the ensure parameter of Apache::Vhost["${vhost}"] is set
    # to present

    if ( ! defined(Apache::Module[proxy])) {
        # Enable apache proxy module
        apache::module {'proxy':
            ensure => $ensure,
            notify => Exec[$apache::params::gracefulrestart],
        }
    }
    if ( ! defined(Apache::Module[proxy_http])) {
        # Enable apache proxy module
        apache::module {'proxy_http':
            ensure => $ensure,
            notify => Exec[$apache::params::gracefulrestart],
        }
    }
    if ( ! defined(Apache::Module[proxy_connect])) {
        # Enable apache proxy module
        apache::module {'proxy_connect':
            ensure => $ensure,
            notify => Exec[$apache::params::gracefulrestart],
        }
    }
    if ( ! defined(Apache::Module[headers]) and $headers != {} ) {
        # Enable apache proxy module
        apache::module {'headers':
            ensure => $ensure,
            notify => Exec[$apache::params::gracefulrestart],
        }
    }

    # if content is passed, use that, else if source is passed use that
    $real_content = $content ? {
        '' => $source ? {
            ''      => template('apache/vhost-reverse-proxy.erb'),
            default => undef
        },
        default => undef
    }
    $real_source = $source ? {
        '' => undef,
        default => $content ? {
            ''      => $source,
            default => undef
        }
    }

    # TODO: access the value of Apache::Vhost["${vhost}"][priority]
    # Problem: I don't know how to deal with it.
    $priority = '010'
    $vhost_file = $apache::use_ssl ? {
        true    => "${apache::params::vhost_availabledir}/${priority}-${vhost}-ssl${apache::params::vhost_extension}",
        default => "${apache::params::vhost_availabledir}/${priority}-${vhost}${apache::params::vhost_extension}"
    }


    if (     regsubst($target_url, '^https.*', 'https') == 'https'
        and ! defined(Concat::Fragment["apache_vhost_${vhost}_proxy_settings"])
      ) {

        concat::fragment { "apache_vhost_${vhost}_proxy_settings":
            ensure  => $ensure,
            target  => $vhost_file,
            order   => '49',
            content => '

    SSLProxyEngine on
    SSLProxyVerify none

',
            notify  => Exec[$apache::params::gracefulrestart],
        }
    }

    concat::fragment { "apache_vhost_${vhost}_proxy_${source_path}":
        ensure  => $ensure,
        target  => $vhost_file,
        order   => $order,
        content => $real_content,
        source  => $real_source,
        notify  => Exec[$apache::params::gracefulrestart],
    }
}


