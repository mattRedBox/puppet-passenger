class puppet-passenger::server {
  $puppet_port = '8140'
  case $::operatingsystem {
    'centOS': {
      $apache_confdir = '/etc/httpd/conf.d'
      $puppet_confdir = '/etc/puppet'
      $vardir = '/var/lib/puppet'
      $ssldir = "$vardir/ssl"
      $rackdir = "$puppet_confdir/rack"
    }
  }
  
  file { "$rackdir":
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
  }
  ->
  file { "$rackdir/public":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
  }
  ->
  file { "$rackdir/config.ru":
    content => template('puppet-passenger/config.ru.erb'),
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  ->
  file { "$apache_confdir/puppetmaster.conf":
    content => template('puppet-passenger/vhost.conf.erb'),
    owner   => 'root',
    group   => 'root',
    ensure  => file,
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  -> 
  file { "$apache_confdir/headers.conf":
    ensure => file,
    source => 'puppet:///modules/puppet-passenger/headers.conf',
  }
  ->
  service {'puppetmaster':
    ensure => stopped,
    enable => false,
  }
  ->
  service {'httpd':
    ensure => running,
    enable => true,
  }
}
