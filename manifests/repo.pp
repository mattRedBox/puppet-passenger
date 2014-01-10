class puppet-passenger::repo {
  include puppet-passenger::defaults

  Exec {
    path   => $defaults::exec_path,
    logoutput => true,
  }

  $name1_short = "epel-release"
  $name1_long = "epel-release-6-8.noarch.rpm"
  $name2_short = "passenger-release"
  $name2_long = "passenger-release.noarch.rpm"

  package { ['httpd','rubygems','mod_ssl','mod_passenger'] :
    ensure => installed,
  }
  ->
  case $::operatingsystem {
    'CentOS' : {
      exec { "rpm -Uv http://download.fedoraproject.org/pub/epel/$::operatingsystemmajrelease/$::architecture/$name1_long":
        unless => "/bin/rpm -q --quiet $name1_short", 
      }
      ->
      exec { "rpm -Uv http://passenger.stealthymonkeys.com/rhel/$::operatingsystemmajrelease/$name2_long":
        unless => "/bin/rpm -q --quiet $name2_short", 
      }
    }
  }
  ->
  yumrepo { 'passenger':
    priority => 10,
  }
}
