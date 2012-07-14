name    'apache'
version '0.1.9'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license 'GPL v3'
summary      'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
description  'Manages apache servers, remote restarts, and mod_ssl, mod_php, mod_python, mod_perl'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'apache::administration, apache::dev, apache::params, apache, apache::common, apache::debian, apache::redhat'
## List of the definitions defined in this module
definitions 'sudo, openssl, concat'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'sudo' 
dependency 'openssl' 
dependency 'concat' 
