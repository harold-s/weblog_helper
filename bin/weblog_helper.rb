# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require_relative '../lib/weblog_helper'

WeblogHelper::CLI.new.execute
