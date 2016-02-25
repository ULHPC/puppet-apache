# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box:
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {

    class { 'apache':
        use_ssl => true,
        use_php => true
    }

    apache::vhost { 'myvhost.my.org':
        ensure                       => 'present',
        use_ssl                      => true,
        aliases                      => [ '10.42.42.42' ],
        enable_default               => true,
        redirect_ssl                 => true,
        ssl_cert_organisational_unit => 'My Org'
    }

    apache::vhost::directory { '/var/www/site-old':
        ensure   => 'present',
        vhost    => 'myvhost.my.org',
        options  => 'Indexes FollowSymLinks MultiViews',
        diralias => '/old',
        comment  => 'Old site',
    }

    apache::vhost::reverse_proxy { '/admin/':
        ensure     => 'present',
        vhost      => 'myvhost.my.org',
        target_url => 'http://10.42.42.24/',
        comment    => 'Administrative services',
        order      => 50
    }

    class { 'apache::diskcache':
        ensure                 => 'present',
        cache_root             => '/var/cache/apache2/mod_disk_cache/',
        cache_path             => ['/'],
        cachedirlevels         => 2,
        cachedirlength         => 2,
        cachemaxfilesize       => 100000000,
        cacheignorenolastmod   => 'On',
        cachemaxexpire         => 300,
        cacheignorequerystring => 'Off'
    }

}
