# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'apache::params'

$names = ["ensure", "protocol", "port", "packagename"]

notice("apache::params::ensure = ${apache::params::ensure}")
notice("apache::params::protocol = ${apache::params::protocol}")
notice("apache::params::port = ${apache::params::port}")
notice("apache::params::packagename = ${apache::params::packagename}")

#each($names) |$v| {
#    $var = "apache::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
