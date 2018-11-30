# == Class ssm::config
#
# This class is called from ssm::init to config the SSM Agent.
#
# == Parameters
#
# [*proxy_host*]
#   proxy_host to be used by ssm agent, <HOST-ADDR>:<PORT>
#
class ssm::config(
  $proxy_host = $ssm::params::proxy_host,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  if $proxy_host {
    file { '/lib/systemd/system/amazon-ssm-agent.service':
      ensure  => present,
      content => template('ssm/amazon-ssm-agent.systemd'),
      notify  => Service[$service_name],
    } ~> exec { 'ssm-systemd-reload':
      command     => 'systemctl daemon-reload',
      path        => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      logoutput   => on_failure,
      notify      => Service[$service_name],
      refreshonly => true,
    }
  }

}
