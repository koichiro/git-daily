# -*- coding: utf-8 -*-

require "git-daily/command/release"

module Git
  module Daily
    class Hotfix < Release

      def initialize
        @base_branch = Command.master
        @branch_prefix = 'hotfix'
        @release_branch_prefix =  'release'
      end

      def help
        "hotfix\tOperation hotfix release"
      end

      def merge_branches
        rel_branches = Command.release_branches(@release_branch_prefix)
        if rel_branches.empty?
          return [Command.master, Command.develop]
        else
          return [Command.master, @release_branch_prefix]
        end
      end

      def usage
        <<-EOS
Usage: git daily hotfix open        : Open hotfix-release process
   or: git daily hotfix list        : Show hotfix list
   or: git daily hotfix sync        : Sync current opened hotfix process
   or: git daily hotfix close       : Close to hotfix-release process
EOS
      end
    end
  end
end
