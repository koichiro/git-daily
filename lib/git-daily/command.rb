# -*- coding: utf-8 -*-

module Git
  module Daily
    class Command
      def initialize
      end

      def run
        raise NotImplementedError.new("You most implement run.")
      end

      def help
        raise NotImplementedError.new("You most implement help.")
      end

      def usage
        raise NotImplementedError.new("You most implement usage.")
      end

      def self.remotes
        `git config --list --no-color`.split(/\n/).select {|a| a[/^remote\.([^\.]+)\.url/] }
      end

      def self.branches
        r = `git branch --no-color`.split(/\n/)
        r.map! { |b| b[/^\*/] ? b[2 .. -1] : b.strip }
      end

      def self.has_branch?(branch)
        r = branches
        r.find {|i| i == branch } ? true : false
      end

      def self.remote
        r = `git config gitdaily.remote`
        r.chomp!
        r.empty? ? nil : r
      end

      def self.main
        r = `git config gitdaily.main`
        r.chomp!
        r.empty? ? master : r
      end

      def self.master
        r = `git config gitdaily.master`
        r.chomp!
        r.empty? ? nil : r
      end

      def self.develop
        r = `git config gitdaily.develop`
        r.chomp!
        r.empty? ? nil : r
      end

      def self.logurl
        r = `git config gitdaily.logurl`
        r.chomp!
        r.empty? ? nil : r
      end

      def self.pull_request_url
        r = `git config gitdaily.pullRequestUrl`
        r.chomp!

        return r unless r.empty?

        remote = self.remote
        if remote
          url_format = "https://github.com/%s/%s/pull/%s"
          github = `git config remote.#{remote}.url`
          github.chomp!

          github.match(/^git@github\.com:(?<org>.+)\/(?<repo>.+)\.git$/) do |match|
            r = sprintf(url_format, match[:org], match[:repo], "%d")
          end
        end

        r.empty? ? nil : r
      end

      def self.current_branch
        r = `git branch --no-color`.split(/\n/)
        master = r.select { |v| v[/^\*/] }
        return nil if master.empty?
        master[0][/^\* (.*)/, 1]
      end

      def self.remote_branch(remote, current_branch)
        r = `git branch --no-color -a`.split(/\n/).select { |a| a[/remotes\/#{remote}\/#{current_branch}/] }
        return nil if r.empty?
        r[0].strip
      end

      def self.has_remote_branch?(remote, branch)
        if remote_branch(remote, branch)
          true
        else
          false
        end
      end

      def self.clean?
        r = `git status -uno -s`.split(/\n/)
        r.empty? ? true : false
      end

      def self.release_branches(branch)
        r = `git branch --no-color`.split(/\n/).select { |a| a[/#{branch}/] }
        r.map! { |b| b[/^\*/] ? b[2 .. -1] : b.strip }
      end

      def self.merged_branches
        r = `git branch --no-color --merged`.split(/\n/)
        r.map! { |b| b[/^\*/] ? b[2 .. -1] : b.strip }
      end
    end
  end
end
