# == Class ssm::register
#
# This class is called from ssm::init to register the SSM Agent.
#
# == Parameters
#
# [*activation_code*]
#   Activation Code provided by System manager upon creation of an activation. Required.
#
# [*activation_id*]
#   Activation ID provided by System manager upon creation of an activation. Required.
#
# [*region*]
#   String indicating the AWS region in which the instance is running. Required.
#   Defaults to `undef`.
#
# [*service_name*]
#   String indicating the name of the SSM service. The correct value is
#   automatically determined based on the platform.
#
# [*proxy_host*]
#   proxy_host to be used by ssm agent, <HOST-ADDR>:<PORT>
#
class ssm::register(
  $activation_code  = $ssm::params::acivation_code,
  $activation_id    = $ssm::params::activation_id,
  $service_name     = $ssm::params::service_name,
  $region           = $ssm::params::region,
  $proxy_host       = $ssm::params::proxy_host,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  $proxy_args = $proxy_host ? {
    false    => undef,
    default  => [ "http_proxy=http://${proxy_host}", "https_proxy=https://${proxy_host}"],
  }

  if ($activation_code) and ($activation_id) {
    exec { 'register-ssm-agent':
      command     => "amazon-ssm-agent -register -code ${activation_code} -id ${activation_id} -region ${region}",
      path        => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      environment => $proxy_args,
      logoutput   => on_failure,
      timeout     => 600,
      notify      => Service[$service_name],
      creates     => '/var/lib/amazon/ssm/Vault/Store/RegistrationKey',
    }
  }

}
