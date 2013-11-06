
    group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

class {'apt':
  always_apt_update => true,
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

apt::ppa { 'ppa:ondrej/php5': }

file { '/home/vagrant/.bash_aliases':
  ensure => 'present',
  source => 'puppet:///modules/puphpet/dot/.bash_aliases',
}

package { [
    'build-essential',
    'vim',
    'curl'
  ]:
  ensure  => 'installed',
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }

apache::vhost { 'server.dev':
  server_name   => 'server.dev',
  serveraliases => [
],
  docroot       => '/var/www/',
  port          => '80',
  env_variables => [
    'APP_ENV development'
  ],
  priority      => '1',
}

class { 'php':
  service       => 'apache',
  module_prefix => '',
  require       => Package['apache'],
}

php::module { 'php5-mysql': }
php::module { 'php5-cli': }
php::module { 'php5-curl': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}





class { 'xdebug':
  service => 'apache',
}

class { 'composer':
  require => Package['php5', 'curl'],
}

puphpet::ini { 'xdebug':
  value   => [
    'xdebug.default_enable = 1',
    'xdebug.remote_autostart = 0',
    'xdebug.remote_connect_back = 1',
    'xdebug.remote_enable = 1',
    'xdebug.remote_handler = "dbgp"',
    'xdebug.remote_port = 9000'
  ],
  ini     => '/etc/php5/conf.d/zzz_xdebug.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'php':
  value   => [
    'date.timezone = "Europe/Madrid"'
  ],
  ini     => '/etc/php5/conf.d/zzz_php.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'custom':
  value   => [
    'display_errors = On',
    'error_reporting = -1'
  ],
  ini     => '/etc/php5/conf.d/zzz_custom.ini',
  notify  => Service['apache'],
  require => Class['php'],
}


class { 'mysql::server':
  config_hash   => { 'root_password' => 'root', 'bind_address' => '0.0.0.0' }
}

database_user { 'root@%':
  password_hash => mysql_password('root')
}

database_grant { 'root@%':
  privileges => ['all', 'Grant_priv'],
}

