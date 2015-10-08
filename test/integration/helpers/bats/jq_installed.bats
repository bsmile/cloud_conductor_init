#! /usr/bin/env bats
#
load test_helper

@test "package jq is installed" {
  run bash -c "yum list installed | grep jq\."
  [ "$status" -eq 0 ]
}

@test "executable jq command is found" {
  run test -x /usr/bin/jq
  [ $status -eq 0 ]
}

@test "executable jq version is 1.3" {

  os_version=$(rpm -qf --queryformat="%{VERSION}" /etc/redhat-release)
  if [ $os_version -ne 6 ]; then
    skip
  fi

  run jq --version
  assert_success "jq version 1.3"
}

@test "executable jq version is 1.5" {

  os_version=$(rpm -qf --queryformat="%{VERSION}" /etc/redhat-release)
  if [ $os_version -ne 7 ]; then
    skip
  fi

  run bash -c "yum list jq | grep ^jq | awk '{ print \$2 }'"
  assert_success "1.5-1.el7"
}
