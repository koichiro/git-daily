# -*- coding: utf-8 -*-

module Git
  module Daily
    class Version < Command
      def help
        "version\tShow version"
      end

      def run
        puts "git-daily : version #{Git::Daily::VERSION}"
      end
    end
  end
end
