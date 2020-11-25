# -*- coding: utf-8 -*-

module Git
  module Daily
    class Config < Command

      SUBCOMMAND = {
        "remote" => lambda {
          r = remotes
          r.map! {|url| url[/^remote\.([^\.]+)\.url=(.*)/, 1] }
          selected_url = ARGV.shift
          if r.find {|v| v == selected_url }
            `git config gitdaily.remote #{selected_url}`
            puts "Your remote is [#{selected_url}]"
          else
            raise "no such remote url: #{selected_url}"
          end
        },
        "develop" => lambda {
          b = branches
          input = ARGV.shift
          if b.find { |v| v == input }
            `git config gitdaily.develop #{input}`
            puts "Your development branch is [#{input}]"
          else
            raise "no such branch: #{input}"
          end
        },
        "main" => lambda {
          b = branches
          input = ARGV.shift
          if b.find { |v| v == input }
            `git config gitdaily.main #{input}`
            puts "Your main branch is [#{input}]"
          else
            raise "no such branch: #{input}"
          end
        },
        "logurl" => lambda {
          url = ARGV.shift
          `git config gitdaily.logurl #{url}`
          puts "Your log url is [#{url}]"
        }
      }

      def help
        "config\tSet or show config"
      end

      def run
        subcommand = ARGV.shift
        if SUBCOMMAND.has_key?(subcommand)
          return SUBCOMMAND[subcommand].call
        end

        # show config
        r = `git config --list`.split(/\n/).select {|a| a[/^gitdaily/] }
        if r.empty?
          raise "git-daily: not initialized. please run: git daily init"
        else
          r.each do |s|
            puts s
          end
        end
        r
      end

      def usage
        <<-EOS
Usage: git daily config remote origin

Example:

    Remote name :
        git daily config remote origin

    Branch name of develop :
        git daily config develop develop

    Branch name of main :
        git daily config main main

    URL template for dump list (will dump commit hash instead of "%s") :
        GitWeb :  git daily config logurl "http://example.com/?p=repositories/example.git;a=commit;h=%s"
        GitHub :  git daily config logurl "https://github.com/sotarok/git-daily/commit/%s"
EOS
      end
    end
  end
end
