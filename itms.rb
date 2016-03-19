#!/usr/bin/env ruby

require 'set'
require 'JSON'
require_relative 'itms_utils.rb'
require_relative 'itms_app_store.rb'
require_relative 'itms_iap.rb'
require_relative 'itms_achievements.rb'
require_relative 'itms_leaderboards.rb'

config_filename = 'itms.config'

if ARGV.include? '-c'
  config_filename_index = ARGV.index('-c') + 1
  config_filename = ARGV[config_filename_index]
end

skip_download = ARGV.include? '--skip-download'

unless File.exists? config_filename
  puts "[ITMS] Could not find config filename #{config_filename}"
  exit 1
end

config = JSON.parse(File.read(config_filename))
username = config['username']
password = config['password']
vendor_id = config['vendor_id']
version = config['version']

destination = '.'
itms_package_name = "#{vendor_id}.itmsp"

log_name = 'itms.log'

if File.exists? log_name
  File.truncate(log_name, 0)
end

unless skip_download
  puts "[ITMS] Downloading itms package #{vendor_id}"
  # Download the itms package to get a stub
  unless ITMSUtils.download_metadata(username, password, vendor_id, destination, log_name)
    puts "[ITMS] [ERROR] Failed to download itms package #{vendor_id}, check #{log_name} for more info"
    exit 2
  end
end

unless File.exists? File.expand_path(itms_package_name)
  puts "[ITMS] Missing itms package for #{vendor_id}"
  exit 3
end

if config['generate_app_store_xml']
# Generate the app store xml and copy the images needed for upload
  puts "[ITMS] Generating App Store xml..."
  base_image_names = config['app_store_image_base_names']
  if !config['upload_app_store_screenshots']
    base_image_names = nil
  end
  app_store_xml, images_used = ITMSAppStore.app_store_xml(version, 'app_store/app_store_locales.tsv', 'app_store', base_image_names)
  ITMSUtils.copy_images(images_used, itms_package_name)
end

if config['generate_iap_xml']
# Generate the iap xml and copy the images needed for upload
  puts "[ITMS] Generating In App Purchases xml..."
  iap_xml, images_used = ITMSIAP.iap_xml('iap/iap_metadata.csv', 'iap/iap_locales.csv', 'iap')
  ITMSUtils.copy_images(images_used, itms_package_name)
end

if config['generate_achievements_xml']
# Generate the achievements xml and copy the images needed for upload
  puts "[ITMS] Generating Achievements xml..."
  achievements_xml, images_used = ITMSAchievements.achievements_xml('achievements/achievements_metadata.csv', 'achievements/achievements_locales.csv', 'achievements')
  ITMSUtils.copy_images(images_used, itms_package_name)
end

if config['generate_leaderboards_xml']
# Generate the leaderboards xml and copy the images needed for upload
  puts "[ITMS] Generating Leaderboards xml..."
  leaderboards_xml, images_used = ITMSLeaderboards.leaderboards_xml('leaderboards/leaderboards_metadata.csv', 'leaderboards/leaderboards_locales.csv', 'leaderboards')
  ITMSUtils.copy_images(images_used, itms_package_name)
end

# Replace the stubbed xml we downloaded with
puts "[ITMS] Replacing itms package metadata with generated xml..."
metadata_filename = "#{itms_package_name}/metadata.xml"
ITMSUtils.replace_xml(metadata_filename, version, app_store_xml, iap_xml, achievements_xml, leaderboards_xml)

package_filepath = "#{destination}/#{itms_package_name}"
# Verify if needed
if config['verify']
  puts "[ITMS] Verifying itms package #{vendor_id}"
  unless ITMSUtils.verify_metadata(username, password, package_filepath, log_name)
    puts "[ITMS] [ERROR] Failed to verify metadata for itms package #{vendor_id}, check #{log_name} for more info"
    exit 4
  end
end

# Submit if needed
if config['upload_after_verify']
  puts "[ITMS] Uploading itms package #{vendor_id}"
  unless ITMSUtils.upload_metadata(username, password, package_filepath, log_name)
    puts "[ITMS] [ERROR] Failed to submit metadata for itms package #{vendor_id}, check #{log_name} for more info"
    exit 5
  end
end

# Clean if needed
if config['clean_after_submit']
  puts "[ITMS] Cleaning up itms package"
  `rm -rf #{itms_package_name}`
end

puts "[ITMS] Complete!"