# frozen_string_literal: true

module WeblogHelper
  class CLIRequiredFileName < StandardError; end
  class CLIFileNotFound < StandardError; end

  class CLI
    def execute
      raise CLIRequiredFileName unless file_name
      raise CLIFileNotFound unless File.file?(file_name)

      WeblogHelper::Filter.new(file_name, IPAddr.new(opts['ip'])).execute
    end

    private

    def file_name
      @file_name ||= opts.arguments.first
    end

    def opts
      @opts ||= Slop.parse do |o|
        o.string '--ip', 'IP or IP CIDR', required: true
        o.on '-h', '--help' do
          puts <<~HEREDOC
            #{o}\nThis program filters logs based on IP or IP CIDR
            Example
            #{$PROGRAM_NAME} --ip 178.93.28.59 /var/log/nginx/access.log
            #{$PROGRAM_NAME} --ip 180.76.15.0/24 /var/log/nginx/access.log
            #{$PROGRAM_NAME} --ip 2001:0db8:85a3:0000:0000:8a2e:0370:7334 /var/log/nginx/access.log
            #{$PROGRAM_NAME} --ip 2001:db8:85a3::8888/24 /var/log/nginx/access.log
          HEREDOC
          exit(0)
        end
      end
    end
  end
end
