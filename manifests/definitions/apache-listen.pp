# File::      <tt>apache-listen.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
# ------------------------------------------------------------------------------
# = Defines: apache::listen
#
# This definition adds a "Listen" directive to apache's port.conf file.
#
# == Pre-requisites
#
# * The class 'apache' should have been instanciated
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent'
#   Default: 'present'
#
# [*comment*]
#  An optional comment to add on top of the listen entry
#
# [*content*]
#  Specify the contents of the Directory directive as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*order*]
#  Set the order of the listen definition (typically between 10 and 90).
#  Default: 50
#
# [*source*]
#  Copy a file as the content of the Directory directive.
#  Uses checksum to determine when a file
#  should be copied. Valid values are either fully qualified paths to files, or
#  URIs. Currently supported URI types are puppet and file.
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#    apache::listen { "8140":
#        ensure  => 'present',
#        comment => 'Puppet master using Passenger' 
#    }
#
#    This will results in the following entry in the ports.conf file:
#
#       ##### Puppet master using Passenger
#       NameVirtualHost *:8140
#       Listen          8140
#
#    
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::listen(
    $ensure     = 'present',
    $content    = '',
    $source     = '',
    $comment    = '',
    $order      = 50
)
{

    include apache::params

    # $name is provided by define invocation and is should be set to the
    # directory path
    $listenport = $name

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache::listen 'ensure' parameter must be set to either 'absent', or 'present'")
    }
    if ($apache::ensure != $ensure) {
        if ($apache::ensure != 'present') {
            fail("Cannot configure the Listen directive '${listenport}' as apache::ensure is NOT set to present (but ${apache::ensure})")
        }
    }

    # if content is passed, use that, else if source is passed use that
    $real_content = $content ? {
        '' => $source ? {
            ''      => template('apache/listen.erb'),
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

    concat::fragment { "apache-ports.conf_${listenport}":
        target  => "${apache::params::ports_file}",
        ensure  => "${ensure}",
        order   => $order,
        content => $real_content,
        source  => $real_source,
        notify  => Exec["${apache::params::gracefulrestart}"],
    }
}


