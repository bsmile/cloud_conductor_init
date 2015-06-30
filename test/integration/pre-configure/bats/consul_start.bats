#! /usr/bin/env bats

load test_helper

@test "consul data dir is not Empty" {
  run ls -Al /var/lib/consul
  assert_success
  [ ${#lines[*]} -gt 0 ]
}

@test "consul Errro is not found into Log" {
  run grep "Error|Failed" /var/log/consul.log
  assert_failure
}

@test "consul is running" {
  run service consul status
  assert_equal "${lines[0]}" "consul is running"
}
