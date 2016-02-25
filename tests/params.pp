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

$names = ["ensure", "protocol", "port", "ssl_port", "use_ssl", "use_php", "redirect_ssl", "admin_group", "cache_root", "cache_path", "cachedirlevels", "cachedirlength", "cachemaxfilesize", "cacheignorenolastmod", "cachemaxexpire", "cacheignorequerystring", "packagename", "dev_packages", "php_packages", "php_extensions", "mod_security_packagename", "servicename", "processname", "hasstatus", "hasrestart", "user", "group", "configdir", "configdir_mode", "configfile_mode", "configdir_owner", "configdir_group", "configdir_seltype", "otherconfigdir", "ports_file", "ports_template", "ports_file_default_entry", "vhost_availabledir", "vhost_enableddir", "vhost_default", "vhost_extension", "default_vhost_file", "default_vhost_link", "disk_cache_template", "mods_availabledir", "mods_enableddir", "wwwdir", "wwwdir_mode", "wwwdir_owner", "wwwdir_group", "htdocs_mode", "cgidir", "cgidir_mode", "cgidir_owner", "cgidir_group", "cgidir_seltype", "logdir", "logdir_mode", "logdir_owner", "logdir_group", "logdir_seltype", "privatedir_seltype", "allow_override", "certificates_seltype", "gracefulrestart", "configtest", "a2enmod", "a2dismod", "a2ensite", "a2dissite", "admin_cmd"]

notice("apache::params::ensure = ${apache::params::ensure}")
notice("apache::params::protocol = ${apache::params::protocol}")
notice("apache::params::port = ${apache::params::port}")
notice("apache::params::ssl_port = ${apache::params::ssl_port}")
notice("apache::params::use_ssl = ${apache::params::use_ssl}")
notice("apache::params::use_php = ${apache::params::use_php}")
notice("apache::params::redirect_ssl = ${apache::params::redirect_ssl}")
notice("apache::params::admin_group = ${apache::params::admin_group}")
notice("apache::params::cache_root = ${apache::params::cache_root}")
notice("apache::params::cache_path = ${apache::params::cache_path}")
notice("apache::params::cachedirlevels = ${apache::params::cachedirlevels}")
notice("apache::params::cachedirlength = ${apache::params::cachedirlength}")
notice("apache::params::cachemaxfilesize = ${apache::params::cachemaxfilesize}")
notice("apache::params::cacheignorenolastmod = ${apache::params::cacheignorenolastmod}")
notice("apache::params::cachemaxexpire = ${apache::params::cachemaxexpire}")
notice("apache::params::cacheignorequerystring = ${apache::params::cacheignorequerystring}")
notice("apache::params::packagename = ${apache::params::packagename}")
notice("apache::params::dev_packages = ${apache::params::dev_packages}")
notice("apache::params::php_packages = ${apache::params::php_packages}")
notice("apache::params::php_extensions = ${apache::params::php_extensions}")
notice("apache::params::mod_security_packagename = ${apache::params::mod_security_packagename}")
notice("apache::params::servicename = ${apache::params::servicename}")
notice("apache::params::processname = ${apache::params::processname}")
notice("apache::params::hasstatus = ${apache::params::hasstatus}")
notice("apache::params::hasrestart = ${apache::params::hasrestart}")
notice("apache::params::user = ${apache::params::user}")
notice("apache::params::group = ${apache::params::group}")
notice("apache::params::configdir = ${apache::params::configdir}")
notice("apache::params::configdir_mode = ${apache::params::configdir_mode}")
notice("apache::params::configfile_mode = ${apache::params::configfile_mode}")
notice("apache::params::configdir_owner = ${apache::params::configdir_owner}")
notice("apache::params::configdir_group = ${apache::params::configdir_group}")
notice("apache::params::configdir_seltype = ${apache::params::configdir_seltype}")
notice("apache::params::otherconfigdir = ${apache::params::otherconfigdir}")
notice("apache::params::ports_file = ${apache::params::ports_file}")
notice("apache::params::ports_template = ${apache::params::ports_template}")
notice("apache::params::ports_file_default_entry = ${apache::params::ports_file_default_entry}")
notice("apache::params::vhost_availabledir = ${apache::params::vhost_availabledir}")
notice("apache::params::vhost_enableddir = ${apache::params::vhost_enableddir}")
notice("apache::params::vhost_default = ${apache::params::vhost_default}")
notice("apache::params::vhost_extension = ${apache::params::vhost_extension}")
notice("apache::params::default_vhost_file = ${apache::params::default_vhost_file}")
notice("apache::params::default_vhost_link = ${apache::params::default_vhost_link}")
notice("apache::params::disk_cache_template = ${apache::params::disk_cache_template}")
notice("apache::params::mods_availabledir = ${apache::params::mods_availabledir}")
notice("apache::params::mods_enableddir = ${apache::params::mods_enableddir}")
notice("apache::params::wwwdir = ${apache::params::wwwdir}")
notice("apache::params::wwwdir_mode = ${apache::params::wwwdir_mode}")
notice("apache::params::wwwdir_owner = ${apache::params::wwwdir_owner}")
notice("apache::params::wwwdir_group = ${apache::params::wwwdir_group}")
notice("apache::params::htdocs_mode = ${apache::params::htdocs_mode}")
notice("apache::params::cgidir = ${apache::params::cgidir}")
notice("apache::params::cgidir_mode = ${apache::params::cgidir_mode}")
notice("apache::params::cgidir_owner = ${apache::params::cgidir_owner}")
notice("apache::params::cgidir_group = ${apache::params::cgidir_group}")
notice("apache::params::cgidir_seltype = ${apache::params::cgidir_seltype}")
notice("apache::params::logdir = ${apache::params::logdir}")
notice("apache::params::logdir_mode = ${apache::params::logdir_mode}")
notice("apache::params::logdir_owner = ${apache::params::logdir_owner}")
notice("apache::params::logdir_group = ${apache::params::logdir_group}")
notice("apache::params::logdir_seltype = ${apache::params::logdir_seltype}")
notice("apache::params::privatedir_seltype = ${apache::params::privatedir_seltype}")
notice("apache::params::allow_override = ${apache::params::allow_override}")
notice("apache::params::certificates_seltype = ${apache::params::certificates_seltype}")
notice("apache::params::gracefulrestart = ${apache::params::gracefulrestart}")
notice("apache::params::configtest = ${apache::params::configtest}")
notice("apache::params::a2enmod = ${apache::params::a2enmod}")
notice("apache::params::a2dismod = ${apache::params::a2dismod}")
notice("apache::params::a2ensite = ${apache::params::a2ensite}")
notice("apache::params::a2dissite = ${apache::params::a2dissite}")
notice("apache::params::admin_cmd = ${apache::params::admin_cmd}")

#each($names) |$v| {
#    $var = "apache::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
