require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rubygems' 
require 'rake/gempackagetask' 
require File.dirname(__FILE__) + "/config/environment"
load APP_ROOT + "/vendor/behaviors/tasks/behaviors_tasks.rake"
Gem::manage_gems

GEM_NAME = "pcan"
GEM_VERSION = "0.9.1"

def get_file_list
  files = []
  [
    FileList['lib/**/*'],
    FileList['vendor/behaviors/**/*'],
    FileList['vendor/cmock/**/*'],
    FileList['test/unit/**/*'],
    'config/environment.rb',
    'test/test_helper.rb',
    'doc/readme.txt',
    'LICENSE',
    'INSTALL',
  ].each do |additional_file|
    files << additional_file
  end  
  files.flatten
end

gem_spec = Gem::Specification.new do |spec|
  spec.name = GEM_NAME
  spec.version = GEM_VERSION
  spec.author = "Atomic Object, LLC"
  spec.email = "williams@atomicobject.com"
  spec.homepage = "http://www.atomicobject.com"
  spec.platform = Gem::Platform::CURRENT
  spec.summary = "Ruby driver for pCAN USB device"
  spec.files = get_file_list
  spec.has_rdoc = false
end

Rake::GemPackageTask.new(gem_spec) do
end

# Constants.
CLOBBER.include('Makefile')
CLOBBER.include('mkmf.log')
CLEAN.include('*.def')

NEW_PATH_VARS = [
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Common7\IDE',
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\bin'
]

NEW_INCLUDE_VARS = [
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\PlatformSDK\Include',
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\include'
]

NEW_LIB_VARS = [
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\PlatformSDK\Lib',
  'C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\lib'
]

# Helpers.
def shell_wrapper(command)
  original_path = ENV['PATH']
  original_include = ENV['INCLUDE']
  original_lib = ENV['LIB']

  ENV['PATH'] = [NEW_PATH_VARS, ENV['PATH']].flatten.join(';')
  ENV['INCLUDE'] = [NEW_INCLUDE_VARS, ENV['INCLUDE']].flatten.join(';')
  ENV['LIB'] = [NEW_LIB_VARS, ENV['LIB']].flatten.join(';')

  begin
    sh command
  ensure
    ENV['PATH'] = original_path
    ENV['INCLUDE'] = original_include
    ENV['LIB'] = original_lib
  end
end

# Tasks.
desc "Build the PCAN extension Makefile"
file "Makefile" => 'extconf.rb' do
  ruby 'extconf.rb --with-pcan-dir=vendor/pcan'
end

desc "Install the pcan extension using Rubygems"
task :install => :gem do
  sh "gem.bat install pkg/pcan-#{GEM_VERSION}-i386-mswin32.gem"
end

desc "Uninstall the pcan extension using Rubygems"
task :uninstall do
  sh "gem.bat uninstall pcan"
end

desc "Build the PCAN extension"
task :build => "Makefile" do
  shell_wrapper 'nmake'
  cp 'PcanHardware.so', 'lib'
end

task :clean => "Makefile" do
  shell_wrapper 'nmake clean'
end

test = namespace :test do
  desc "Run the unit test suite"
  Rake::TestTask.new(:units => :build) do |t|
    t.pattern = "test/unit/**/*_test.rb"
    t.verbose = true
  end
  
  desc "Run the system test suite"
  task :system => :build do
    require 'systir'
    require "#{SYSTEST_ROOT}/pcan_driver.rb"
    result = Systir::Launcher.new.find_and_run_all_tests(PcanDriver, SYSTEST_ROOT)
    raise "SYSTEM TESTS FAILED" unless result.passed?
  end

end

desc "Build the PCAN extension and run the test suite"
task :default => [:build, test[:units]]

desc "Clean, build, run unit tests, and run system tests"
task :all => [:clean, :build, test[:units], test[:system]]
