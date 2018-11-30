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
class ssm::register(
  $activation_code = $ssm::params::acivation_code,
  $activation_id    = $ssm::params::activation_id,
  $region          = $ssm::params::region,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  if ($activation_code) and ($activation_id) {
    exec { 'register-ssm-agent':
      command   => "amazon-ssm-agent -register -code ${activation_code} -id ${activation_id} -region ${region}",
      path      => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
      logoutput => on_failure,
      timeout   => 600,
      creates   => '/var/lib/amazon/ssm/Vault/Store/RegistrationKey',
    }
  }

}
