name       'apache'
version    '0.1.4'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
description 'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'apache::params, apache, apache::common, apache::debian, apache::redhat, apache::dev, apache::administration'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'openssl'
dependency 'sudo'
dependency 'concat'
defines    '["apache::module", "apache::vhost", "apache::vhost::reverse", "apache::vhost::directory"]'
