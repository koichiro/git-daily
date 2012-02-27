# -*- coding: utf-8 -*-

module Git
  module Daily
    class Help < Command

      def help
        "help\tShow help (run \"help {subcommand}\" to get more help)"
      end

      def run
        subcommand = ARGV.shift
        if Git::Daily.application.commands.has_key?(subcommand)
          $stderr.puts Git::Daily.application.commands[subcommand].usage
        else
          $stderr.puts usage
        end
      end

      def usage
        r = <<-EOS
git-daily: command [options]

Usage:

EOS
        Git::Daily.application.commands.keys.sort.each do |key|
          r += "    #{Git::Daily.application.commands[key].help}\n"
        end
        r += "\n"
      end
    end
  end
end
