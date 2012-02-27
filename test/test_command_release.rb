# -*- coding: utf-8 -*-

require 'test/unit'
require 'git-daily'
require 'git-daily/command/init'

class TestCommandRelease < Test::Unit::TestCase
  def setup
    @command = Git::Daily::Release.new
  end

  def test_relase_open
    @command.open
  end

  def test_release_list
    @command.list
  end

  def teardown
    $stdin = STDIN
  end
end
