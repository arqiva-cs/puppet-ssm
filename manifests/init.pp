# == Class: ssm
#
# Downloads and installs the amazon-ssm-agent, i.e. the EC2 run command agent
#
# == Parameters
#
# [*custom_path*]
#   String indicating the location where the package will be downloaded. If the
#   path specified is not present, the module will create it.
#   Defaults to `/opt/amazon-ssm-agent.${package}`.
#
# [*custom_url*]
#   String indicating the URL to use when downloading the SSM package.
#   Defaults to the standard URL for the AWS region specified in `ssm::region`.
#
# [*flavor*]
#   String specifying the OS flavor. This is used when building the default
#   download URL. The correct value is automatically set based on the platform.
#
# [*manage_service*]
#   Bool. If set, the module will manage the SSM service. Defaults to `true`.
#
# [*package*]
#   String representing the package type. The correct type, either `rpm` or
#   `deb`, is automatically set based on the platform.
#
# [*provider*]
#   String indicating the type of package provider to use when installing the
#   SSM agent. The correct type, either `rpm` or `dpkg`, is automatically set
#   based on the platform.
#
# [*region*]
#   String indicating the AWS region in which the instance is running. Required.
#   Defaults to `undef`.
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
# == Examples
#
# @example
#    class { 'ssm':
#      region => 'us-east-1',
#    }
#
# == Authors
#
# Todd Courtnage <todd@courtnage.ca>
# Shawn Sterling <shawn@systemtemplar.org>
#
# == Copyright
#
# Copyright 2016 Todd Courtnage
#
# lint:ignore:80chars
#
class ssm (
  $custom_path     = $ssm::params::custom_path,
  $custom_url      = $ssm::params::custom_url,
  $flavor          = $ssm::params::flavor,
  $manage_service  = $ssm::params::manage_service,
  $package         = $ssm::params::package,
  $provider        = $ssm::params::provider,
  $region          = $ssm::params::region,
  $activation_code = $ssm::params::activation_code,
  $activation_id   = $ssm::params::activation_id,
  $proxy_host      = $ssm::params::proxy_host,
  $service_enable  = $ssm::params::service_enable,
  $service_ensure  = $ssm::params::service_ensure,
  $service_name    = $ssm::params::service_name,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  if $custom_url {
    validate_string($custom_url)
    $url = "${custom_url}/amazon-ssm-agent.${package}"
  } else {
    $url = "amazon-ssm-${region}.s3.amazonaws.com/latest/${flavor}_amd64/amazon-ssm-agent.${package}"
  }

  if $custom_path {
    validate_absolute_path($custom_path)
    if ! defined($custom_path) {
      exec { "mkdir_p-${custom_path}":
        command => "mkdir -p ${custom_path}",
        unless  => "test -d ${custom_path}",
        path    => '/bin:/usr/bin',
      }
      file { $custom_path:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Exec["mkdir_p-${custom_path}"],
      }
    }
    $path = "${custom_path}/amazon-ssm-agent.${package}"
  } else {
    $path = "/opt/amazon-ssm-agent.${package}"
  }

  ensure_packages(['wget'], {ensure => present})

  class { 'ssm::install':
    path     => $path,
    provider => $provider,
    url      => $url,
  }

  class { 'ssm::config':
    proxy_host => $proxy_host,
  }

  class { 'ssm::register':
    activation_code => $activation_code,
    activation_id   => $activation_id,
    region          => $region,
  }

  class { 'ssm::service':
    manage_service => $manage_service,
    service_enable => $service_enable,
    service_ensure => $service_ensure,
    service_name   => $service_name,
  }

  anchor { 'ssm::begin': } -> Class['ssm::install'] ->  Class['ssm::config'] -> Class['ssm::register'] -> Class['ssm::service'] -> anchor { 'ssm::end': }
  # lint:endignore
}
