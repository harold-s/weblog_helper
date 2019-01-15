# frozen_string_literal: true

RSpec.describe WeblogHelper::CLI do
  describe '#execute' do
    subject(:execute) { described_class.new.execute }

    let(:argv) { ['--ip', ip, file_name] }
    let(:file_name) { File.join('examples', 'public_access.log.txt') }
    let(:filter_instance) do
      instance_double(WeblogHelper::Filter, execute: true)
    end

    before do
      allow($stdout).to receive(:puts)
      stub_const('ARGV', argv)
      allow(WeblogHelper::Filter).to receive(:new).and_return(filter_instance)
    end

    context 'when --ip is a valid IPv4' do
      let(:ip) { '178.93.28.59' }

      it { expect { execute }.not_to raise_error }
      it do
        execute
        expect(WeblogHelper::Filter).to\
          have_received(:new).with(file_name, IPAddr.new(ip))
      end
    end

    context 'when --ip is a valid IPv4 with CIDR' do
      let(:ip) { '178.93.28.59/24' }

      it { expect { execute }.not_to raise_error }
    end

    context 'when --ip is a valid IPv6' do
      let(:ip) { '2001:0db8:85a3:0000:0000:8a2e:0370:7334' }

      it { expect { execute }.not_to raise_error }
    end

    context 'when --ip is a valid IPv6 with CIDR' do
      let(:ip) { '2001:db8:85a3::8888/32' }

      it { expect { execute }.not_to raise_error }
    end

    context 'when --ip is not valid IPv4' do
      let(:ip) { '256.0.0.0' }

      it { expect { execute }.to raise_error(IPAddr::InvalidAddressError) }
    end

    context 'when --ip is not valid IPv6' do
      let(:ip) { 'g001:db8:85a3::8a2e:370:7334' }

      it { expect { execute }.to raise_error(IPAddr::InvalidAddressError) }
    end

    context 'when --ip is not an IP' do
      let(:ip) { 'The quick brown fox jumps over the lazy dog' }

      it { expect { execute }.to raise_error(IPAddr::InvalidAddressError) }
    end

    context 'when --ip missing' do
      let(:argv) { [file_name] }

      it { expect { execute }.to raise_error(Slop::MissingRequiredOption) }
    end

    context 'when file argument is missing' do
      let(:argv) { ['--ip', '178.93.28.59'] }

      it {
        expect { execute }.to\
          raise_error(WeblogHelper::CLIRequiredFileName)
      }
    end

    context 'when file does not exists' do
      let(:file_name) { '/var/log/nginx/access.log' }
      let(:ip) { '178.93.28.59' }

      it { expect { execute }.to raise_error(WeblogHelper::CLIFileNotFound) }
    end

    context 'when file is not a file' do
      let(:file_name) { 'spec' }
      let(:ip) { '178.93.28.59' }

      it { expect { execute }.to raise_error(WeblogHelper::CLIFileNotFound) }
    end

    context 'when --help' do
      let(:argv) { ['--help'] }

      it { expect { execute }.to raise_error(SystemExit) }
    end
  end
end
