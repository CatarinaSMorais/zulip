class zulip::stats {
  class { 'zulip::base': }
  class { 'zulip::apache': }
  class { 'zulip::supervisor': }

  $stats_packages = [ "libssl-dev", "zlib1g-dev", "python-twisted", "python-django", "python-django-tagging",
                      "python-carbon", "python-cairo", "python-graphite-web", "python-whisper", "redis-server" ]
  package { $stats_packages: ensure => "installed" }

  file { "/root/setup_disks.sh":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => 744,
    source => 'puppet:///modules/zulip/graphite/setup_disks.sh',
  }
  file { "/etc/cron.d/graphite_backup":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/cron.d/graphite_backup",
  }
  exec { "setup_disks":
    command => "/root/setup_disks.sh",
    creates => "/srv/graphite"
  }

  file { "/etc/ssl/certs/stats1.zulip.net.crt":
    require => File["/etc/apache2/certs/"],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 640,
    source => "/root/zulip/certs/stats1.zulip.net.crt",
  }

  file { "/opt/graphite/conf/carbon.conf":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/carbon.conf",
  }
  file { "/opt/graphite/conf/aggregation-rules.conf":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/aggregation-rules.conf",
  }
  file { "/opt/graphite/conf/storage-aggregation.conf":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/storage-aggregation.conf",
  }
  file { "/opt/graphite/conf/storage-schemas.conf":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/storage-schemas.conf",
  }
  file { "/opt/graphite/webapp/graphite/local_settings.py":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/local_settings.py",
  }
  file { "/opt/graphite/conf/graphite.wsgi":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/graphite/graphite.wsgi",
  }

  file { "/home/zulip/graphiti/config/settings.yml":
    ensure => file,
    owner  => "zulip",
    group  => "zulip",
    mode => 644,
    source => "puppet:///modules/zulip/graphiti/settings.yml",
  }

  apache2site { 'graphite':
    require => [File['/etc/apache2/sites-available/'],
                Apache2mod['headers'], Apache2mod['ssl'],
                ],
    ensure => present,
  }
  apache2site { 'graphiti':
    require => [File['/etc/apache2/sites-available/'],
                Apache2mod['headers'], Apache2mod['ssl'],
                ],
    ensure => present,
  }

  file { "/etc/redis/redis.conf":
    require => Package[redis-server],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/statsd/redis.conf",
  }
  service { 'redis-server':
    ensure     => running,
    subscribe  => File['/etc/redis/redis.conf'],
  }

  file { "/etc/supervisor/conf.d/stats.conf":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/supervisor/conf.d/stats.conf",
  }
}
