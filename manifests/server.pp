class puppet-passenger::server {
  $puppet_port = '8140'
  case $operatingsystem {
    'centOS': {
      $apache_confdir = '/etc/httpd/httpd.conf'
      $puppet_confdir = '/etc/puppet'
      $vardir = '/var/lib/puppet'
      $ssldir = "$vardir/ssl"
      $rackdir = "$puppet_confdir/rack"
    }
  }

  file { "$apache_confdir/puppetmaster.conf":
    content => template('puppet-passenger/vhost.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  ->
  file { "$rackdir/config.ru":
    content => template('puppet-passenger/config.ru.erb'),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  ->
  file { "$rackdir/public":
    ensure  => directory,
    mode    => '755',
  }
  ->
  service {'httpd':
    ensure => running,
    enable => true,
  }
  ->
  service {'puppetmaster':
    ensure => stopped,
    enable => false,
  }
}
