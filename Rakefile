# frozen_string_literal: true

require 'minitest/test_task'
require 'rake/clean'

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
module Overnight # rubocop:disable Style/Documentation
  autoload :Nightscout, 'overnight/nightscout'
end

Minitest::TestTask.create

SAMPLE_DIR = 'test/overnight/nightscout/data'
directory SAMPLE_DIR
CLEAN << SAMPLE_DIR

task sample_data: SAMPLE_DIR do
  sources = FileList['lib/overnight/nightscout/contracts/*.rb']
  filenames = sources.exclude('**/authorization.rb').map { it.pathmap('%n') }
  nightscout_data = nil

  filenames.each do |filename|
    path = File.join(SAMPLE_DIR, filename).ext('json')
    next if File.exist?(path)

    nightscout_data ||= Overnight::Nightscout.new.get(validate: false)
    File.write(path, JSON.pretty_generate(nightscout_data[filename.to_sym]))
  end
end

task test: :sample_data
task default: :test
