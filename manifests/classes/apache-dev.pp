# File::      <tt>apache-dev.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# Time-stamp: <Tue 2011-09-13 18:22 svarrette>
# ------------------------------------------------------------------------------
# = Class: apache-dev
#
# This class installs Apache development libraries
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of the libraries
#
# == Requires:
#
# n/a
#
# == Sample usage:
#
#     include apache::dev
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class apache::dev($ensure = $apache::ensure) inherits apache {

    info ("Configuring apache::dev (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("apache::dev 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    package { $apache::params::dev_packages:
        ensure => "${apache::dev::ensure}",
    }

}



