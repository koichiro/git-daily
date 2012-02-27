# -*- coding: utf-8 -*-

module Git
  module Daily
    class Push < Command

      def help
        "push\tPush local to remote (for only same branch)"
      end

      def run
        remote = Command.remote
        if remote.empty?
          raise "no remote setting"
        end

        current_branch = Command.current_branch
        unless current_branch
          raise "not on any branches"
        end

        remote_branch = Command.remote_branch(remote, current_branch)
        unless remote_branch
          raise "note remote branch named: #{current_branch}"
        end

        puts "run git push #{remote} #{current_branch}"
        r = `git push #{remote} #{current_branch}`
        puts r
        unless $?.success?
          $stderr.puts "git push failed:"
          raise "git push failed"
        end
        puts "push completed"
      end

      def usage
        <<-EOS
Usage: git daily push
EOS
      end
    end
  end
end
