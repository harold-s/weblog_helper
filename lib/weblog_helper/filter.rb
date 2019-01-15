# frozen_string_literal: true

module WeblogHelper
  class Filter
    REGEX_IP = /^(?<ip>[^\s]+)/.freeze
    attr_reader :file_name, :ip
    def initialize(file_name, ip)
      @file_name = file_name
      @ip = ip
    end

    def execute
      f = File.open(file_name, 'r')
      f.each_line { |line| execute_line(line) }
      f.close
    end

    private

    def execute_line(line)
      line_ip_str = line.match(REGEX_IP)&.named_captures&.dig('ip')
      return unless line_ip_str

      begin
        line_ip = IPAddr.new(line_ip_str)
        puts line if ip.include?(line_ip)
      rescue IPAddr::InvalidAddressError
        return
      end
    end
  end
end
