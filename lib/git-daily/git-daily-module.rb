require "git-daily/application"

module Git
  module Daily
    class << self
      def application
        @application ||= Git::Daily::Application.new
      end

      def application=(app)
        @application = app
      end

      def original_dir
        application.original_dir
      end
    end
  end
end
