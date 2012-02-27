# -*- coding: utf-8 -*-

require "git-daily/command/release"

module Git
  module Daily
    class Hotfix < Release

      def initialize
        @base_branch = "master"
        @merge_to = ["master", "develop", "release"]
        @branch_prefix = 'hotfix'
      end

      def help
        "hotfix\tOperation hotfix release"
      end

      def merge_branches
        rel_branches = Command.release_branches("release")
        if rel_branches.empty?
          return ["master", "develop"]
        else
          return ["master", "release"]
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
