# Weblog helper assessment

## Requirements
  Easiest way yo run this project is to use [Docker](https://github.com/docker/docker-ce) (tested on `18.09.1`).
  It is possible to use a `ruby` provided by your system.

## Run
  If using docker :
  ```bash
    # weblog_helper.sh will build docker project and run it (mounting log file in the docker container)
    ./weblog_helper.sh --help
    ./weblog_helper.sh --ip 178.93.28.59 examples/public_access.log.txt
    ./weblog_helper.sh --ip 180.76.15.0/24 examples/public_access.log.txt
    ./weblog_helper.sh --ip 2001:888:197d:0:250:fcff:fe23:3879 examples/apache_ipv6_access.log
    ./weblog_helper.sh --ip 2001:db8::/32 examples/apache_ipv6_access.log
  ```

  If using non dockerized `ruby`
  ```bash
    bundle install
    ruby ./bin/weblog_helper.rb  --ip 178.93.28.59 examples/public_access.log.txt
  ```

## Technical Stack
  - [Docker](https://github.com/docker/docker-ce)
  - [Ruby](https://www.ruby-lang.org/en/) `2.6`
  - [rspec](https://github.com/rspec/rspec) `3.8.0`
  - [rubocop](https://github.com/rubocop-hq/rubocop) `0.62.0`

## Comments
 - I used `Ruby` because it is my strongest language.
 - This program has been developed in the mindset of maintainability and simplicity while keeping performances acceptable.
 - Use of `Docker` is mainly to be easily develop and ensure that you can run this program the same I run it. "Production" deployment might need to be done in a different way.
 - Logic of [weblog_helper.sh](weblog_helper.sh) has not been tested because it's meant for you to test this program.
 - I took the liberty of taking the filename as an argument to be able to test different files
 - I used the Gem [slop](https://github.com/leejarvis/slop) to manage option parsing. It ensures options `--ip` and that the filename are present.
 - I kept to Unit testing (no integration tests).
 - Use of [IO#each_line](https://ruby-doc.org/core-2.6/IO.html#method-i-each_line) is important to ensure we only read file line by line and do not load the file in memory. (logs can be very large)
 - I relied on [IPAddr](https://ruby-doc.org/stdlib-2.6/libdoc/ipaddr/rdoc/IPAddr.html) to parse and validate IP. This class can take IPv4 and IPv6 addresses. As cost was near-zero to add IPv6 support (and IPv6 would not raise exceptions, but parts of the code might not be compatible), I've added support for IPv6 to this program and tested it.
 - [WeblogHelper::Filter](spec/lib/weblog_helper/filter_spec.rb) tests could have fixtures in an external file, but I thought it would be easier for your to review with them in the specs.
 - IP Separator in the example logs is ` - - `. I've only used one white space to be potentially compatible with more log formats. `Regexp` in [WeblogHelper::Filter](lib/weblog_helper/filter.rb#L5) could be easily changed
 - If IP is not found or IP format is incorrect, I have chosen to silently fail on the line. This decision is mostly based on the fact I've seen a few times log lines which had some `\n` in them. Line would be invalid anyway and this program is not here to verify the integrity of the logs.

 # Tests
 This program has [rspec](https://github.com/rspec/rspec)  for tests and [rubocop](https://github.com/rubocop-hq/rubocop) for static code analysing and formatting.
 ```bash
   docker build -t weblog_helper .
   docker run --rm weblog_helper rspec
   docker run --rm weblog_helper rubocop
 ```

# Dev
```bash
  docker build -t weblog_helper .
  docker run -it --rm --mount type=bind,source="$(pwd)",target=/usr/src/app weblog_helper bash
```
