#!/bin/sh

metronome_install_dir='/opt/cloudconductor/bin'
metronome_config_dir='/etc/metronome'

install_metronome() {
  rm -rf ${metronome_install_dir}/metronome
  remote_file http://download.cloudconductor.org/tools/metronome-0.1.0 \
      ${metronome_install_dir}/metronome \
      || return $?

  chmod 755 ${metronome_install_dir}/metronome || return $?

  directory ${metronome_config_dir} root:root 755 || return $?

  values=(`echo $http_proxy | tr -s '/:' ' '`)
  proxy_host=${values[1]}
  proxy_port=${values[2]}

  files="$root_dir/task.yml"
  for name in `echo ${PATTERNS_JSON} | jq -r 'keys | .[]'`
  do
    files=$root_dir/patterns/$name/task.yml,$files
  done

  file_copy ${tmpls_dir}/default/config.yml ${metronome_config_dir}/config.yml root:root 644 || return $?
  sed -i \
      -e "s@__role__@${ROLE}@g" \
      -e "s@__token__@'${CONSUL_SECRET_KEY}'@g" \
      ${metronome_config_dir}/config.yml \
      || return $?

  if [ -n "${proxy_host}" ]; then
    sed -i \
        -e "s@__proxy-host__@${proxy_host}@g" \
        ${metronome_config_dir}/config.yml \
        || return $?
  else
    sed -i \
        -e "/__proxy-host__/d" \
        ${metronome_config_dir}/config.yml \
        || return $?
  fi

  if [ -n "${proxy_port}" ]; then
    sed -i \
        -e "s@__proxy-port__@${proxy_port}@g" \
        ${metronome_config_dir}/config.yml \
        || return $?
  else
    sed -i \
        -e "/__proxy-port__/d" \
        ${metronome_config_dir}/config.yml \
        || return $?
  fi

  if [ -n "${no_proxy}" ]; then
    sed -i \
        -e "s@__no-proxy__@${no_proxy}@g" \
        ${metronome_config_dir}/config.yml \
        || return $?
  else
    sed -i \
        -e "/__no-proxy__/d" \
        ${metronome_config_dir}/config.yml \
        || return $?
  fi

  sed -i \
      -e "s@__files__@${files}@g" \
      ${metronome_config_dir}/config.yml \
      || return $?

  if [ ! -f /etc/init.d/metronome ]; then
    ${metronome_install_dir}/metronome install || return $?
  fi
}
