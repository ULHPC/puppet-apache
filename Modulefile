name    'apache'
version '0.3.0'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license 'GPL v3'
summary      'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
description  'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'apache::params, apache, apache::common, apache::debian, apache::redhat, apache::dev, apache::diskcache, apache::diskcache::common, apache::diskcache::debian, apache::diskcache::redhat, apache::administration'
## List of the definitions defined in this module
definitions 'openssl, concat, sudo'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'openssl' 
dependency 'concat' 
dependency 'sudo' 
