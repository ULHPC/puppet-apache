# File::      <tt>apache-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: apache::params
#
# In this class are defined as variables values that are used in other
# apache classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class apache::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of apache
    $ensure = $apache_ensure ? {
        ''      => 'present',
        default => "${apache_ensure}"
    }

    # The Protocol used. Used by monitor and firewall class. Default is 'tcp'
    $protocol = $apache_protocol ? {
        ''      => 'tcp',
        default => "${apache_protocol}",
    }
    # The port number. Used by monitor and firewall class. The default is 80.
    $port = $apache_port ? {
        ''      => [ '80' ],
        default => $apache_port,
    }

    # The SSL port number. Used by monitor and firewall class. The default is 443.
    $ssl_port = $apache_ssl_port ? {
        ''      => [ '443' ],
        default => $apache_ssl_port,
    }

    # Whether or not to activate SSL for virtual hosts
    $use_ssl = $apache_use_ssl ? {
        ''      => false,
        default => "${apache_use_ssl}",
    }

    # Whether or not to activate PHP
    $use_php = $apache_use_php ? {
        ''      => false,
        default => "${apache_use_php}",
    }

    # Whether or not to redirect http requests to https (require mod_rewrite)
    $redirect_ssl  = $apache_redirect_ssl ? {
        ''      => false,
        default => "${apache_redirect_ssl}",
    }

    # This is the name of the group configured in sudoers to manage apache
    $admin_group = $apache_admin_group ? {
        ''      => 'apache-admin',
        default => "${apache_admin_group}",
    }


    # https://httpd.apache.org/docs/2.2/mod/mod_disk_cache.html
    $cache_root = $apache_cache_root ?
    {
      ''      => '/var/cache/apache2/mod_disk_cache',
      default => "${apache_cache_root}",
    }

    $cache_path = $apache_cache_path ?
    {
      ''      => ['/'],
      default => "${apache_cache_path}",
    }

    $cachedirlevels = $apache_cachedirlevels ?
    {
      ''      => 2,
      default => "${apache_cachedirlevels}",
    }

    $cachedirlength = $apache_cachedirlength ?
    {
      ''      => 1,
      default => "${apache_cachedirlength}",
    }

    $cachemaxfilesize = $apache_cachemaxfilesize ?
    {
      ''      => 100000000,
      default => "${apache_cachemaxfilesize}",
    }

    $cacheignorenolastmod = $apache_cacheignorenolastmod ?
    {
      ''      => 'On',
      default => "${apache_cacheignorenolastmod}",
    }

    $cachemaxexpire = $apache_cachemaxexpire ?
    {
      ''      => '300',
      default => "${apache_cachemaxexpire}",
    }

    $cacheignorequerystring = $apache_cacheignorequerystring ?
    {
      ''      => 'Off',
      default => "${apache_cacheignorequerystring}",
    }

    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    # package for apache2
    $packagename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'apache2',
        /(?i-mx:centos|fedora|redhat)/ => 'httpd',
        default => 'apache2'
    }

    # associated dev packages
    $dev_packages = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => [ 'libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev' ],
        /(?i-mx:centos|fedora|redhat)/ => [ 'httpd-devel' ],
        default => [ 'apache-dev' ]
    }

    # to activate PHP with apache
    $php_packages = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => [ 'libapache2-mod-php5' ],
        /(?i-mx:centos|fedora|redhat)/ => [ 'php' ],
        default => [ 'php' ]
    }

    $php_extensions = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => [ 'php5-ldap', 'php5-gd', 'php5-mcrypt', 'php5-curl', 'php-pear', 'php5-xmlrpc', 'php5-xsl' ],
        /(?i-mx:centos|fedora|redhat)/ => [ 'php-ldap', 'php-gd', 'php-mcrypt', 'php-pear', 'php-xmlrpc', 'php-xml' ],
        default => [ 'php5-ldap' ]
    }

    # to activate the security module
    $mod_security_packagename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'libapache-mod-security',
        /(?i-mx:centos|fedora|redhat)/ => 'mod_security',
        default => [ 'apache-security' ]
    }

    $servicename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'apache2',
        /(?i-mx:centos|fedora|redhat)/ => 'httpd',
        default => 'apache2'
    }

    # used for pattern in a service ressource
    $processname = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'apache2',
        /(?i-mx:centos|fedora|redhat)/ => 'httpd',
        default => 'apache2'
    }

    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }

    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    # user to run (and own) apache service/files
    $user = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'www-data',
        /(?i-mx:centos|fedora|redhat)/ => 'apache',
        default => 'www-data'
    }

    # group to run (and own) apache service/files
    $group = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'www-data',
        /(?i-mx:centos|fedora|redhat)/ => 'apache',
        default => 'www-data'
    }

    # Main config dir
    $configdir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => '/etc/apache2',
        /(?i-mx:centos|fedora|redhat)/ => '/etc/httpd',
        default => '/etc/apache2',
    }
    $configdir_mode = $::operatingsystem ? {
        default => '0755',
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }
    $configdir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $configdir_group = $::operatingsystem ? {
        default => 'root',
    }
    $configdir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'httpd_config_t',
        default => undef,
    }

    $otherconfigdir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => '/etc/apache2/conf.d',
        /(?i-mx:centos|fedora|redhat)/ => '/etc/httpd/conf.d',
        default => '/etc/apache2/conf.d',
    }

    # Ports.conf template file (NameVirtualHost + Listen directives)
    $ports_file = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => "${configdir}/ports.conf",
        /(?i-mx:centos|fedora|redhat)/ => "${otherconfigdir}/ports.conf",
        default => "${configdir}/ports.conf"
    }
    $ports_template = $::operatingsystem ? {
        default => 'ports.conf.erb',
    }
    $ports_file_default_entry = $::operatingsystem ? {
        default => "${ports_file}_default_entry"
    }


    # Virtual host dir
    $vhost_availabledir = $::operatingsystem ? {
        default => "$configdir/sites-available",
    }
    $vhost_enableddir = $::operatingsystem ? {
        default => "$configdir/sites-enabled",
    }
    # Default virtual host template file
    $vhost_default = $::operatingsystem ? {
        default => 'default-vhost.erb',
    }

    # Default disk cache config file
    $disk_cache_template = $::operatingsystem ? {
        default => 'disk_cache.erb',
    }

    # Apache modules dir
    $mods_availabledir = $::operatingsystem ? {
        default => "$configdir/mods-available",
    }
    $mods_enableddir = $::operatingsystem ? {
        default => "$configdir/mods-enabled",
    }


    # WWW data dir
    $wwwdir = $::operatingsystem ? {
        default => "/var/www",
    }
    $wwwdir_mode = $::operatingsystem ? {
        default => '0755',
    }
    $wwwdir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $wwwdir_group = $::operatingsystem ? {
        default => 'root',
    }
    $htdocs_mode = $::operatingsystem ? {
        default => '0775',
    }

    # cgi-bin dir
    $cgidir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => '/usr/lib/cgi-bin',
        /(?i-mx:centos|fedora|redhat)/ => '/var/www/cgi-bin',
        default => '/usr/lib/cgi-bin',
    }
    $cgidir_mode = $::operatingsystem ? {
        default => '0755',
    }
    $cgidir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $cgidir_group = $::operatingsystem ? {
        default => 'root',
    }
    $cgidir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'httpd_sys_script_exec_t',
        default => undef,
    }

    # Apache2 log directory
    $logdir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => '/var/log/apache2',
        /(?i-mx:centos|fedora|redhat)/ => '/var/log/httpd',
        default => '/var/log/apache',
    }
    $logdir_mode = $::operatingsystem ? {
        default => '0755',
    }
    $logdir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $logdir_group = $::operatingsystem ? {
        default => 'adm',
    }
    $logdir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'httpd_log_t',
        default => undef,
    }

    # Vhost private data
    $privatedir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'httpd_sys_content_t',
        default => undef,
    }

    # Whether or not to authorize htaccess configuration
    $allow_override = $::operatingsystem ? {
        default => "None",
    }

    # Certificates
    $certificates_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'cert_t',
        default => undef,
    }


    # Graceful restart command
    # See http://httpd.apache.org/docs/2.0/stopping.html
    $gracefulrestart = $::operatingsystem ? {
        default => 'apache2ctl graceful',
    }

    # Command to run a configuration file syntax test.
    # See http://httpd.apache.org/docs/2.0/stopping.html
    $configtest = $::operatingsystem ? {
        default => 'apache2ctl configtest',
    }

    # Command to enable an Apache module
    $a2enmod = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/usr/sbin/a2enmod',
        default                 => '/usr/local/sbin/a2enmod'
    }

    # Command to disable an Apache module
    $a2dismod = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/usr/sbin/a2dismod',
        default                 => '/usr/local/sbin/a2dismod'
    }

    # Command to enable an Apache site (aka vhost)
    $a2ensite = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/usr/sbin/a2ensite',
        default                 => '/usr/local/sbin/a2ensite'
    }

    # Command to disable an Apache site (aka vhost)
    $a2dissite = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/usr/sbin/a2dissite',
        default                 => '/usr/local/sbin/a2dissite'
    }

    # This is the list of commands to authorize for the users put in the
    # $apache::admin_group group (inside the /etc/sudoers file)
    $admin_cmd = $apache_admin_group ? {
        /(?i-mx:ubuntu|debian)/        => [ '/usr/sbin/apache2ctl' ],
        /(?i-mx:centos|fedora|redhat)/ => [ '/usr/sbin/apache2ctl', "/sbin/service ${servicename}" ],
        default => [ ],
    }
}

