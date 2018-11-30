# == Class ssm::params
#
# This class is called from ssm::init to set variable defaults.
#
class ssm::params {
  $custom_path     = false
  $custom_url      = false
  $manage_service  = true
  $region          = undef
  $activation_code = false
  $activation_id   = false
  $proxy_host      = false
  $service_enable  = true
  $service_ensure  = 'running'

  case $::operatingsystem {
    'Amazon', 'CentOS', 'OracleLinux', 'RedHat', 'Scientific': {
      $service_name = 'amazon-ssm-agent'
      $package = 'rpm'
      $provider = 'rpm'
      $flavor = 'linux'
    }
    'Debian', 'Ubuntu': {
      $service_name = 'amazon-ssm-agent'
      $package = 'deb'
      $provider = 'dpkg'
      $flavor = 'debian'
    }
    default: {
      fail("Module not supported on ${::operatingsystem}.")
    }
  }
}
