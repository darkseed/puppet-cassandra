class cassandra::install {
    package { 'dsc':
        ensure => installed,
        name   => $cassandra::package_name,
    }

    package { 'python-cql':
        ensure => installed,
    }

    if(($::osfamily == 'Debian') and ($::virtual == 'openvzve')) {
        file { 'CASSANDRA-3636 /etc/sysctl.d/cassandra.conf':
            ensure  => file,
            path    => '/etc/sysctl.d/cassandra.conf',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => '# Workaround for CASSANDRA-3636',
        }
    }

    if($::osfamily == 'Debian') {
        file { 'CASSANDRA-2356 /etc/cassandra':
            ensure => directory,
            path   => '/etc/cassandra',
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
        }

        exec { 'CASSANDRA-2356 Workaround':
            path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
            command => '/etc/init.d/cassandra stop && rm -rf /var/lib/cassandra/*',
            creates => '/etc/cassandra/CASSANDRA-2356',
            user    => 'root',
            require => [
                    Package['dsc'],
                    File['CASSANDRA-2356 /etc/cassandra'],
                ],
        }

        file { 'CASSANDRA-2356 marker file':
            ensure  => file,
            path    => '/etc/cassandra/CASSANDRA-2356',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => '# Workaround for CASSANDRA-2356',
            require => [
                    File['CASSANDRA-2356 /etc/cassandra'],
                    Exec['CASSANDRA-2356 Workaround'],
                ],
        }
    }
}