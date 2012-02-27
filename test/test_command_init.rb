# -*- coding: utf-8 -*-

require 'test/unit'
require 'git-daily'
require 'git-daily/command/init'

class TestCommandInit < Test::Unit::TestCase
  def test_init
    command = Git::Daily::Init.new

    $stdin = File.new(File.join(File.dirname(__FILE__), 'test_init_input.txt'))
    assert_nil command.run
  end

  def teardown
    $stdin.close
    $stdout = STDIN
  end
end
