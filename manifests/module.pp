# File::      <tt>module.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Defines: apache::module
#
# setup an apache module - this is used primarily by apache subclasses
# This type enables or disables the /etc/apache2/mods-enabled/$name symlink by
# calling a2enmod or a2dismod as neccessary.
#
# == Pre-requisites
#
# * The class 'apache' should have been instanciated
#
# == Parameters:
#
# [*ensure*]
#   default to 'present'
#
#
# [*content*]
#  Specify the contents of the module configuration as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*source*]
#  Copy a file as the content of the apache module configuration.
#  Uses checksum to determine when a file
#  should be copied. Valid values are either fully qualified paths to files, or
#  URIs. Currently supported URI types are puppet and file.
#  If content was not specified, you are expected to use the source
#
# == Requires:
#   $content or $source must be set
#
# == Sample Usage:
#    this would install the php.conf which includes the LoadModule,
#    AddHandler, AddType and related info that apache needs
#
#    apache::module{"php":
#        source => "puppet:///modules/apache/php.conf",
#    }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define apache::module($ensure = 'present' #, $content='', $source=''
) {

    include ::apache::params

    # $name is provided by define invocation
    # guid of this entry
    $modulename = $name

    # if content is passed, use that, else if source is passed use that
    # case $content {
    #     '': {
    #         case $source {
    #             '': {
    #                 crit('No content nor source have been  specified')
    #             }
    #             default: { $real_source = $source }
    #         }
    #     }
    #     default: { $real_content = $content }
    # }

    case $ensure {
        'present': {
            # TODO: this might not work if $apache::ensure != present because of
            # the dependency on Service['apache2']... 
            exec { "enable apache module ${name}":
                command => "${apache::params::a2enmod} ${name}",
                unless  => "/bin/sh -c '[ -L ${apache::params::mods_enableddir}/${name}.load ] \\
                && [ ${apache::params::mods_enableddir}/${name}.load -ef ${apache::params::mods_availabledir}/${name}.load ]'",
                before  => Service['apache2'],
                notify  => Exec[$apache::params::gracefulrestart],
                require => Package['apache2'];
            }
        }
        'absent': {
            exec { "disable apache module ${name}":
                command => "${apache::params::a2dismod} ${name}",
                onlyif  => "/bin/sh -c '[ -L ${apache::params::mods_enableddir}/${name}.load ] \\
                && [ ${apache::params::mods_enableddir}/${name}.load -ef ${apache::params::mods_availabledir}/${name}.load ]'",
                before  => Service['apache2'],
                notify  => Exec[$apache::params::gracefulrestart],
                require => Package['apache2'];
            }
        }
        default: {
            fail "Invalid 'ensure' parameter (current value '${ensure}') for apache::module"
        }
    }
}
