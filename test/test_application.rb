require 'test/unit'
require 'git-daily'

class TestApplication < Test::Unit::TestCase
  def test_load_commands
    r = Git::Daily.application.load_commands
    assert(r.detect {|v| v[/config/]})
    assert(r.detect {|v| v[/init/]})
  end
end
