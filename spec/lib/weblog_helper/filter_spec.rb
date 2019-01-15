# frozen_string_literal: true

RSpec.describe WeblogHelper::Filter do
  describe '#execute' do
    subject(:execute) { described_class.new(file_name, ip_addr).execute }

    let(:ip_addr) { IPAddr.new(ip) }
    let(:file_name) { :FILE_NAME }

    before do
      allow($stdout).to receive(:puts)
      allow(File).to receive(:open).with(file_name, 'r')\
                                   .and_return(StringIO.new(file_content))
    end

    context 'when ip is an IPv4 without CIDR and one hit' do
      let(:ip) { '31.184.238.128' }
      let(:file_content) do
        <<~HEREDOC
          #{ip} - - [02/Jun/2015:17:00:12 -0700] "GET /logs/access.log HTTP/1.1" 200 2145998 "http://kmprograf.forumcircle.com" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" "redlug.com"
          157.55.39.180 - - [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          151.80.31.151 - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it do
        execute
        expect($stdout).to\
          have_received(:puts).with(file_content.each_line.first)
      end
    end

    context 'when ip is an IPv4 with CIDR /24 and one hit' do
      let(:ip) { '31.184.238.0/24' }
      let(:file_content) do
        <<~HEREDOC
          31.184.238.123 - - [02/Jun/2015:17:00:12 -0700] "GET /logs/access.log HTTP/1.1" 200 2145998 "http://kmprograf.forumcircle.com" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" "redlug.com"
          157.55.39.180 - - [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          151.80.31.151 - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it do
        execute
        expect($stdout).to\
          have_received(:puts).with(file_content.each_line.first)
      end
    end

    context 'when ip is an IPv4 with CIDR /24 and two hits' do
      let(:ip) { '31.184.238.0/24' }
      let(:file_content) do
        <<~HEREDOC
          31.184.238.123 - - [02/Jun/2015:17:00:12 -0700] "GET /logs/access.log HTTP/1.1" 200 2145998 "http://kmprograf.forumcircle.com" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" "redlug.com"
          31.184.238.230 - - [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          151.80.31.151 - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      before { execute }

      it { expect($stdout).to have_received(:puts).with(file_content.lines[0]) }
      it { expect($stdout).to have_received(:puts).with(file_content.lines[1]) }
    end

    context 'when ip is an IPv6 without CIDR and one hit' do
      let(:ip) { '2001:0db8:85a3:0000:0000:8a2e:0370:7334' }
      let(:file_content) do
        <<~HEREDOC
          #{ip} - - [02/Jun/2015:17:00:12 -0700] "GET /logs/access.log HTTP/1.1" 200 2145998 "http://kmprograf.forumcircle.com" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" "redlug.com"
          b872:4c53:d57e:1f0d:91f1:d541:3054:e660 - - [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          d367:dcdf:6cf2:442:5978:6349:8d58:688f - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it do
        execute
        expect($stdout).to\
          have_received(:puts).with(file_content.each_line.first)
      end
    end

    context 'when ip is an IPv6 with CIDR /24 and one hit' do
      let(:ip) { '2001:db8:85a3::8888/24' }
      let(:file_content) do
        <<~HEREDOC
          2001:0db8:85a3:1119:62ab:fb3f:a1ff:612a - - [02/Jun/2015:17:00:12 -0700] "GET /logs/access.log HTTP/1.1" 200 2145998 "http://kmprograf.forumcircle.com" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36" "redlug.com"
          b872:4c53:d57e:1f0d:91f1:d541:3054:e660 - - [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          d367:dcdf:6cf2:442:5978:6349:8d58:688f - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it do
        execute
        expect($stdout).to\
          have_received(:puts).with(file_content.each_line.first)
      end
    end

    context 'when a log line does not start with an IP' do
      let(:ip) { '31.184.238.128' }
      let(:file_content) do
        <<~HEREDOC
          [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          151.80.31.151 - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it { expect { execute }.not_to raise_error }
      it do
        execute
        expect($stdout).not_to have_received(:puts)
      end
    end

    context 'when a log line starts with an invalid IP' do
      let(:ip) { '31.184.238.128' }
      let(:file_content) do
        <<~HEREDOC
          192.168.0.256 [02/Jun/2015:17:00:46 -0700] "GET /Leaflets/2001/?M=D HTTP/1.1" 200 451 "-" "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "redlug.com"
          151.80.31.151 - - [02/Jun/2015:17:04:32 -0700] "GET /paper2004/0401BNP.htm HTTP/1.1" 200 1354 "-" "Mozilla/5.0 (compatible; AhrefsBot/5.0; +http://ahrefs.com/robot/)" "redlug.com"
        HEREDOC
      end

      it { expect { execute }.not_to raise_error }
      it do
        execute
        expect($stdout).not_to have_received(:puts)
      end
    end
  end
end
