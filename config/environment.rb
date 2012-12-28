APP_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")
SYSTEST_ROOT = APP_ROOT + "/test/system"

# Setup our load path:
[ 'lib',
  'vendor/behaviors/lib',
  'vendor/cmock/lib',
  'vendor/systir'].each do |dir|
  $LOAD_PATH << File.join(APP_ROOT, dir)
end
