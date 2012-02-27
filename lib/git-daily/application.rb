# -*- coding: utf-8 -*-

module Git
  module Daily
    class Application

      attr_reader :original_dir
      attr_reader :options
      attr_reader :commands
      attr_accessor :remote

      def initialize
        @original_dir = Dir.pwd
        @commands = {}
      end

      def options
        @options ||= OpenStruct.new
      end

      def handle_options
        command = ARGV.shift
        if @commands.has_key?(command)
          @commands[command].run
        else
          $stderr.puts @commands["help"].usage
          exit
        end
      end

      def run
        #exception_handling do
          init
        #end
      end

      def init
        #exception_handling do
          load_commands
          handle_options
        #end
      end

      def load_commands
        Dir[File.join(File.dirname(__FILE__), "command", "*.rb")].each do |file|
          load file
          name = File.basename(file, ".rb")
          @commands[name] = Git::Daily.const_get(name.capitalize).new
        end
      end

      def exception_handling
        begin
          yield
        rescue SystemExit => ex
          raise
        rescue OptionParser::InvalidOption => ex
          $stderr.puts ex.message
        rescue Exception => ex
          display_error_message(ex)
          exit(false)
        end
      end

      def display_error_message(ex)
        $stderr.puts "git-daily aborted!"
        $stderr.puts ex.message
        if options.trace
          $stderr.puts ex.backtrace.join("\n")
        end
      end
    end
  end
end
