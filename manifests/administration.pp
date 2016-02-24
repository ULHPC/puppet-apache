# File::      <tt>administration.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: apache::administration
#
# Configure an admin group and the associated sudoers configurations to
# eventually grant apache administration rights to some users.
# Remember that on most platforms, the 'group' resource can only create groups:
# group membership must be managed on individual users.
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of this
# configuration
#
# $admin_group:: *Default*: 'apache-admin'. The name of the group which members
# are grant administration rights on apache
#
# == Requires:
#
# n/a
#
# == Sample usage:
#
#     import 'apache'
#     class apache::administration {
#          ensure      => 'present',
#          group_admin => 'apache-admin',
#     }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class apache::administration (
    $ensure      = $apache::ensure,
    $admin_group = $apache::params::admin_group
)
inherits apache
{
    info ("Configuring apache::administration (with ensure = ${ensure}, admin_group = ${admin_group})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache::administration 'ensure' parameter must be set to either 'absent' or 'present'")
    }
    if ! $admin_group {
        fail("apache::administration 'admin_group parameter must be set")
    }

    group { $admin_group:
        ensure => $ensure,
    }

    include sudo

    # create a user alias - not sure it really makes sense so commented
    # sudo::alias::user { 'APACHE_ADMIN':
    #     ensure   => $ensure,
    #     userlist => "%${admin_group}",
    # }

    sudo::alias::command { 'APACHE_ADMIN':
        ensure  => $ensure,
        cmdlist => [
                    "/etc/init.d/${apache::params::servicename}",
                    "/bin/su ${apache::params::user}",
                    "/bin/su - ${apache::params::user}",
                    $apache::params::admin_cmdlist
                    ],
    }
    
    sudo::directive { "sudo_${admin_group}":
        ensure  => $ensure,
        content => template('apache/sudoers.apache-admin.erb'),
        require => Group[$admin_group],
    }



}