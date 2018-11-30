# == Class ssm::service
#
# This class is called from ssm::init to ensure the SSM service is running.
#
# == Parameters
#
# [*manage_service*]
#   Bool. If set, puppet will manage the SSM service. Defaults to `true`.
#
# [*service_enable*]
#   Bool. If set, the module will ensure the SSM service is enabled and
#   automatically started by the service manager. Only valid when
#   `manage_service` is `true`. Defaults to `true`.
#
# [*service_ensure*]
#   String indicating the desired state of the SSM service. Only valid when
#   `manage_service` is `true`. Defaults to `running`.
#
# [*service_name*]
#   String indicating the name of the SSM service. The correct value is
#   automatically determined based on the platform.
#
class ssm::service(
  $manage_service   = $ssm::params::manage_service,
  $service_enable   = $ssm::params::service_enable,
  $service_ensure   = $ssm::params::service_ensure,
  $service_name     = $ssm::params::manage_service,
  $service_provider = $ssm::params::service_provider,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  if $manage_service {
    case $::operatingsystem {
      'Debian': {
        service { $service_name:
          ensure    => $service_ensure,
          provider  => $service_provider,
          enable    => $service_enable,
          subscribe => Package['amazon-ssm-agent'],
          require   => Class['ssm::install'],
        }
      }
      'Ubuntu': {
        service { $service_name:
          ensure    => $service_ensure,
          provider  => $service_provider,
          enable    => $service_enable,
          subscribe => Package['amazon-ssm-agent'],
          require   => Class['ssm::install'],
        }
      }
      'CentOS': {
        service { $service_name:
          ensure    => $service_ensure,
          provider  => $service_provider,
          enable    => $service_enable,
          subscribe => Package['amazon-ssm-agent'],
          require   => Class['ssm::install'],
        }
      }
      'Amazon': {
        service { $service_name:
          ensure     => $service_ensure,
          provider   => $service_provider,
          hasstatus  => true,
          hasrestart => true,
          restart    => "/sbin/restart ${service_name}",
          start      => "/sbin/start ${service_name}",
          status     => "/sbin/status ${service_name}",
          stop       => "/sbin/stop ${service_name}",
          subscribe  => Package['amazon-ssm-agent'],
          require    => Class['ssm::install'],
        }
      }
      default: {
        service { $service_name:
          ensure     => $service_ensure,
          enable     => $service_enable,
          hasstatus  => true,
          hasrestart => true,
          restart    => "/sbin/restart ${service_name}",
          start      => "/sbin/start ${service_name}",
          status     => "/sbin/status ${service_name}",
          stop       => "/sbin/stop ${service_name}",
          subscribe  => Package['amazon-ssm-agent'],
          require    => Class['ssm::install'],
        }
      }
    }
  }
}
