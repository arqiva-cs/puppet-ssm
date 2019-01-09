# == Class ssm::install
#
# This class is called from ssm::init to install the SSM package.
#
# == Parameters
#
# [*path*]
#   Specifies the location where the package will be downloaded. The path can
#   be set using `ssm::custom_path` othwerwise, the correct default path is
#   generated in ssm::init.
#
# [*provider*]
#  Specifies the provider type to use when installing the package. The correct
#  provider is determined automatically based on platform in ssm::params.
#
# [*url*]
#   String indicating the URL to use when downloading the SSM package. The URL
#   can be set using `ssm::custom_url` otherwise, the correct default URL is
#   generated in ssm::init.
#
# [*proxy_host*]
#   proxy_host to be used by ssm agent, <HOST-ADDR>:<PORT>
#
class ssm::install(
  $path       = undef,
  $provider   = undef,
  $url        = undef,
  $proxy_host = $ssm::params::proxy_host,
) inherits ssm::params { # lint:ignore:class_inherits_from_params_class

  validate_absolute_path($path)
  validate_string($url)

  $proxy_args = $proxy_host ? {
    false    => undef,
    default  => [ 'use_proxy=yes', "http_proxy=http://${proxy_host}", "https_proxy=https://${proxy_host}"],
  }

  package {'wget':
    ensure => installed,
  } ->
  exec { 'download_ssm-agent':
    command     => "/usr/bin/wget -T60 -N https://${url} -O ${path}",
    environment => $proxy_args,
    path        => '/bin:/usr/bin:/usr/local/bin:/usr/sbin',
    creates     => $path,
  } ->
  package { 'amazon-ssm-agent':
    provider  => $provider,
    source    => $path,
    subscribe => Exec['download_ssm-agent'],
  }
}
