# == Class: screen
#
class screen (
  $package_ensure           = 'present',
  $package_name             = $::screen::params::package_name,
  $package_list             = $::screen::params::package_list,

  $config_dir_path          = $::screen::params::config_dir_path,
  $config_dir_purge         = false,
  $config_dir_recurse       = true,
  $config_dir_source        = undef,

  $config_file_path         = $::screen::params::config_file_path,
  $config_file_owner        = $::screen::params::config_file_owner,
  $config_file_group        = $::screen::params::config_file_group,
  $config_file_mode         = $::screen::params::config_file_mode,
  $config_file_source       = undef,
  $config_file_string       = undef,
  $config_file_template     = undef,

  $config_file_require      = $::screen::params::config_file_require,

  $config_file_hash         = {},
  $config_file_options_hash = {},
) inherits ::screen::params {
  validate_re($package_ensure, '^(absent|latest|present|purged)$')
  validate_string($package_name)
  if $package_list { validate_array($package_list) }

  validate_absolute_path($config_dir_path)
  validate_bool($config_dir_purge)
  validate_bool($config_dir_recurse)
  if $config_dir_source { validate_string($config_dir_source) }

  validate_absolute_path($config_file_path)
  validate_string($config_file_owner)
  validate_string($config_file_group)
  validate_string($config_file_mode)
  if $config_file_source { validate_string($config_file_source) }
  if $config_file_string { validate_string($config_file_string) }
  if $config_file_template { validate_string($config_file_template) }

  validate_string($config_file_require)

  validate_hash($config_file_hash)
  validate_hash($config_file_options_hash)

  $config_file_content = default_content($config_file_string, $config_file_template)

  if $config_file_hash {
    create_resources('screen::define', $config_file_hash)
  }

  if $package_ensure == 'purged' {
    $config_dir_ensure  = 'absent'
    $config_file_ensure = 'absent'
  } else {
    $config_dir_ensure  = 'directory'
    $config_file_ensure = 'present'
  }

  validate_re($config_dir_ensure, '^(absent|directory)$')
  validate_re($config_file_ensure, '^(absent|present)$')

  anchor { 'screen::begin': } ->
  class { '::screen::install': } ->
  class { '::screen::config': } ->
  anchor { 'screen::end': }
}