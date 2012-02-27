# -*- coding: utf-8 -*-

module Git
  module Daily
    class Pull < Command

      def help
        "pull\tPull remote to local (for only same branch)"
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

        rebase = false
        OptionParser.new do |opt|
          opt.on('--rebase') { |v| rebase = true }
          opt.parse!(ARGV)
        end

        puts "run git pull #{remote} #{current_branch}#{ rebase ? ' (rebase)' : ''}"
        r = `git pull #{rebase ? '--rebase' : ''} #{remote} #{current_branch}`
        puts r
        unless $?.success?
          $stderr.puts "git pull failed:"
          raise "git pull failed"
        end
        puts "pull completed"
      end

      def usage
        <<-EOS
Usage: git daily pull
   or: git daily pull --rebase
EOS
      end
    end
  end
end
