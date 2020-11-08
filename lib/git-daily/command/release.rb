# -*- coding: utf-8 -*-

require 'date'

module Git
  module Daily
    class Release < Command

      SUBCOMMAND = {
        "open" => :open,
        "list" => :list,
        "sync" => :sync,
        "close" => :close
      } unless const_defined? :SUBCOMMAND

      def initialize
        @base_branch = Command.develop
        @branch_prefix = "release"
        @merge_to = [Command.main, Command.develop]
      end

      def help
        "release\tOperation daily release"
      end

      def run
        unless Command.clean?
          raise "git status is not clean"
        end

        subcommand = ARGV.shift
        if SUBCOMMAND.has_key?(subcommand)
          return send(SUBCOMMAND[subcommand])
        else
          $stderr.puts "please specify release subcommand"
          $stderr.puts usage
          exit 1
        end
      end

      def open
        cur_branch = Command.current_branch
        base_branch = @base_branch
        if cur_branch != base_branch
          raise "currently not on #{base_branch} but on #{cur_branch}"
        end

        rel_branches = Command.release_branches(@branch_prefix)
        unless rel_branches.empty?
          raise "release process (on local) is not closed, so cannot open release\n    release branches: #{rel_branches.join(',')}"
        end

        remote = Command.remote
        if remote
          puts "first, fetch remotes"
          `git fetch --all`

          rels = `git branch -a --no-color`.split(/\n/).select { |b| b[/remotes\/#{remote}\/#{@branch_prefix}/]}
          unless rels.empty?
            raise "release process (on local) is not closed, so cannot open release\n    release branches: #{rels.join(',')}"
          end
        end

        new_release_branch = "#{@branch_prefix}/#{DateTime.now.strftime("%Y%m%d-%H%M")}"
        puts "Confirm: create branch #{new_release_branch} from #{cur_branch} ?"
        print " [yN] : "
        confirm = $stdin.gets
        unless confirm.strip[/^[Yy]/]
          raise "abort"
        end

        # merge current branch
        if remote
          puts "merge #{cur_branch} branch from remote"
          r = `git merge #{remote}/#{cur_branch}`
          unless $? == 0
            $stderr.puts "merge failed"
            $stderr.puts r
            raise "abort"
          end
        end

        # create release branch
        puts "create release branch: #{new_release_branch}"
        r = `git branch #{new_release_branch}`
        if remote
          puts "push to remote: #{remote}"
          r = `git push #{remote} #{new_release_branch}`
          puts r
          unless $? == 0
            $stderr.puts "push failed"
            r = `git branch -d #{new_release_branch}`
            $stderr.puts r
            $stderr.puts "rollback (delete branch)"
          end
        end

        `git checkout #{new_release_branch}`
        puts "release opened"
      end

      def merge_branches
        @merge_to
      end

      def close
        rel_branches = Command.release_branches(@branch_prefix)
        if rel_branches.empty?
          raise "#{@branch_prefix} branch not found. abort."
        end
        rel_branch = rel_branches.shift
        remote = Command.remote

        merge_branches.each do |branch_name|

          branches = `git branch`.split("\n").select{|v| v[/#{branch_name}/]}
          merge_branch = branches[0][/^\*/] ? branches[0][2 .. -1] : branches[0].strip
          next unless merge_branch

          if remote
            puts "first, fetch remotes"
            `git fetch --all`
            puts "diff check"

            diff_branch1 = "#{rel_branch}..#{remote}/#{rel_branch}"
            diff_branch2 = "#{remote}/#{rel_branch}..#{rel_branch}"
            diff1 = `git diff #{diff_branch1}`
            diff2 = `git diff #{diff_branch2}`
            unless diff1.empty? or diff1.empty?
              $stderr.puts "There are some diff between local and $remote, run release sync first."
              raise "abort"
            end
          end

          $stderr.puts "checkout #{merge_branch} and merge #{rel_branch} to #{merge_branch}"
          `git checkout #{merge_branch}`
          if remote
            r = `git daily pull`
            puts r
            unless $? == 0
              $stderr.puts "pull failed"
              raise "abort"
            end
          end

          merged_branches = Command.merged_branches
          unless merged_branches.find {|v| v == rel_branch}
            r = `git merge --no-ff #{rel_branch}`
            puts r
            unless $? == 0
              $stderr.puts "merge failed"
              raise "abort"
            end
          end

          puts "push #{merge_branch} to #{remote}"
          `git checkout #{merge_branch}`
          r = `git push #{remote} #{merge_branch}`
          puts r
          unless $? == 0
            $stderr.puts "push failed"
            raise "abort"
          end
        end

        puts "delete branch: #{rel_branch}"
        r = `git branch -d #{rel_branch}`
        puts r
        unless $? == 0
          $stderr.puts "failed to delete local #{rel_branch}"
          raise "abort"
        end
        if remote
          r = `git push #{remote} :#{rel_branch}`
          puts r
          unless $? == 0
            $stderr.puts "failed to delete #{remote}'s #{rel_branch}"
            raise "abort"
          end
        end

        base = @base_branch
        `git checkout #{base}`
        puts "#{@branch_prefix} closed"

      end

      # Sync release
      def sync
        remote = Command.remote
        unless remote
          raise "remote not found. abort."
        end
        cur = Command.current_branch
        develop = Command.develop

        puts "first, fetch remotes"
        `git fetch --all`
        puts "cleanup remote"
        `git remote prune #{remote}`

        rel = nil
        rel_branches = Command.release_branches(@branch_prefix)
        rel = rel_branches.shift if rel_branches.size == 1

        r_closed = false
        r_rel_branch = nil
        r_rel_branches = `git branch -a`.split(/\n/).select { |a| a[/remotes\/#{remote}\/#{@branch_prefix}/] }
        r_rel_branches.map! { |b| b.strip }
        if r_rel_branches.size == 1
          r_rel_branch = r_rel_branches.shift[/remotes\/#{remote}\/(.*)/, 1]
        else
          if r_rel_branches.empty?
            r_closed = true
          else
            raise "there are a number of remote release branches"
          end
        end

        if rel
          if r_rel_branch != rel
            r_closed = true
          end

          if r_closed
            puts "release closed! so cleanup local release branch"
            puts "checkout #{develop}"
            `git checkout #{develop}`
            r = `git daily pull`
            puts r
            puts "delete #{rel}"
            r = `git branch -d #{rel}`
            puts r
            unless $? == 0
              $stderr.puts "branch delete failed"
              $stderr.puts "    git branch delete failed, please manually"
            end

            if r_rel_branch != rel
              $stderr.puts "Closed old release branch"
              $stderr.puts "Please retry 'release sync'"
            end
            puts "sync to release close"
            return
          end

          if cur != rel
            puts "checkout #{rel}"
            `git checkout #{rel}`
            cur = Command.current_branch
          end

          puts "git pull"
          r = `git daily pull`
          puts r
          unless $? == 0
            raise "abort"
          end

          puts "git push"
          r = `git daily push`
          puts r
          unless $? == 0
            $stderr.puts "failed to push to remote"
            raise "abort"
          end
        else
          if r_closed
            puts "sync completed (nothing to do)"
            return
          end

          puts "checkout and traking #{r_rel_branch}"
          r = `git checkout #{r_rel_branch}`
          puts r
          unless $? == 0
            $stderr.puts "failed to checkout"
            raise "abort"
          end
          puts "start to tracking release branch"
        end
      end

      def list
        release_branch = Command.release_branches(@branch_prefix)
        if release_branch.empty?
          raise "#{@branch_prefix} branch not found. abort."
        end

        current_branch = Command.current_branch

        remote = Command.remote
        main_branch = if remote
                          Command.remote_branch(remote, Command.main)
                        else
                          Command.main
                        end

        puts "first, fetch remotes"
        `git fetch --all`

        revs = []
        rev_ids = `git rev-list --no-merges #{main_branch}..#{current_branch}`.split(/\n/)
        rev_ids.each do |rev_id|
          rev = {}
          rev[:id] = rev_id
          rev[:add_files] = []
          rev[:mod_files] = []

          logs = `git show #{rev_id}`
          file = nil
          logs.each_line do |line|
            case line
            when /^Author: .+\<([^@]+)@([^>]+)>/
              rev[:author] = $1
            when /^diff --git a\/([^ ]+) /
              file = $1
            when /^new file mode/
              rev[:add_files] << file
            when /^index/
              rev[:mod_files] << file
            end
          end

          revs << rev
        end

        mod_files = []
        add_files = []
        revs.each do |rev|
          mod_files += rev[:add_files]
          mod_files += rev[:mod_files]
        end
        mod_files.sort!.uniq!
        add_files.sort!.uniq!

        if revs.size > 0
          puts "Commit list:"
          revs.each do |rev|
            puts "\t#{rev[:id]} = #{rev[:author]}"
          end
          puts
        end

        if add_files.size > 0
          puts "Added files:"
          add_files.each do |file|
            puts "\t#{file}"
          end
          puts
        end

        if mod_files.size > 0
          puts "Modified files:"
          mod_files.each do |file|
            puts "\t#{file}"
          end
          puts
        end

        if Command.logurl and revs.size > 0
          authors = {}
          revs.each do |rev|
            authors[rev[:author]] = [] unless authors[rev[:author]]
            authors[rev[:author]] << rev[:id]
          end

          logurl = Command.logurl
          puts "Author list:"
          authors.keys.sort.each do |key|
            puts "\t#{key}:"
            authors[key].each do |id|
              puts sprintf("\t#{logurl}", id)
            end
            puts
          end
        end

        if Command.pull_request_url
          puts 'Pull Requests: '

          urlBase = Command.pull_request_url
          merges = `git log --merges --pretty=format:'%<(30)%s | %an' #{main_branch}..#{current_branch}`.split(/\n/)

          merges.each do |merge|
            merge.match(/^Merge pull request #(?<id>[1-9][0-9]*) .+$/) do |match|
              url = sprintf(urlBase,  match[:id])
              puts "\t#{url} | #{match[0]}"
            end
          end
        end
      end

      def usage
        <<-EOS
Usage: git daily release open\t: Open daily-release process
       git daily release list\t: Show release list
       git daily release sync\t: Sync current opened release process
       git daily release close\t: Close to daily-release process
EOS
      end
    end
  end
end
