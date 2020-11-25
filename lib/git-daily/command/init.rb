# -*- coding: utf-8 -*-

require "git-daily/command"

module Git
  module Daily
    class Init < Command

      def option
        OptionParser.new
      end

      def help
        "init\tInitialize git daily"
      end

      def run
        r = `git config --bool gitdaily.init`
        if r.chomp == "true"
          # initialized repo
          return nil
        end
        remotes = `git config --list`.split(/\n/).select {|a| a[/^remote\.([^\.]+)\.url/] }
        if remotes.empty?
          raise "don't have remote repository"
        end

        remotes.map! {|r| r[/^remote\.([^\.]+)\.url=(.*)/, 1] }

        selected_url = nil
        if remotes.size >= 2
          puts "Choose your remote url:"
          i = 0
          remotes.each do |v|
            puts "    #{i}: #{v}"
            i += 1
          end
          print "    > "
          n = gets.to_i
          selected_url = remotes[n]
        else
          selected_url = remotes[0]
        end

        r = `git config gitdaily.remote #{selected_url}`
        puts "Your remote is [#{selected_url}]"
        Git::Daily.application.remote = selected_url

        # main branch
        main_default = if Command.has_branch? "main"
                         "main"
                       else
                         "master"
                       end
        print "Name main branch [#{main_default}]: "
        main = gets.strip
        if main.empty?
          main = main_default
        end
        `git config gitdaily.main #{main}`

        # develop branch
        print "Name develop branch [develop]: "
        develop = gets.strip
        if develop.empty?
          develop = "develop"
        end
        `git config gitdaily.develop #{develop}`

        unless Command.has_branch? develop
          remote = Command.remote
          if remote and Command.has_remote_branch?(remote, develop)
            `git checkout #{develop}`
          else
            `git checkout -b #{develop}`
            if remote
              `git push #{remote} #{develop}`
            end
          end
        end

        # initialized
        `git config gitdaily.init true`

        puts
        puts "git-daily completed to initialize."
        selected_url
      end

      def usage
        <<-EOS
Usage: git daily init
EOS
      end
    end
  end
end
