require 'digest'
require 'set'

TRANSPORTER_CMD = 'xcrun iTMSTransporter'

class ITMSUtils
  def self.download_metadata(username, password, app_id, destination, log_name)
    cmd = "#{TRANSPORTER_CMD} -m lookupMetadata -u #{username} -p \"#{password}\" -apple_id #{app_id} -destination #{destination} &> #{log_name}"
    return system(cmd)
  end

  def self.copy_images(image_filenames, destination)
    full_destination_path = File.expand_path(destination)
    image_filenames.each do |image_filename|
      full_image_filepath = File.expand_path(image_filename)
      `cp #{full_image_filepath} #{full_destination_path}`
    end
  end

  def self.image_data_string(image_dir, image_name)
    if !image_name || image_name.length == 0
      raise Exception.new("Image name cannot be blank")
      return
    end

    full_path = "#{image_dir}/#{image_name}"

    if !File.exists?(full_path)
      raise Exception.new("Image cannot be found: #{full_path}")
      return
    end

    output = "<size>#{File.size(full_path)}</size>"
    output += "<file_name>#{image_name}</file_name>"
    output += "<checksum type=\"md5\">#{Digest::MD5.file(full_path).hexdigest}</checksum>"
    output
  end

  def self.locale_row_data_by_id(input_locales)
    locale_row_data_by_id = Hash.new

    input_locales.each do |row_data|
      id = row_data[0]
      all_row_data_for_locale = locale_row_data_by_id[id]
      if all_row_data_for_locale.nil?
        all_row_data_for_locale = Array.new
      end
      all_row_data_for_locale << row_data
      locale_row_data_by_id[id] = all_row_data_for_locale
    end

    locale_row_data_by_id
  end

  def self.replace_xml(metadata_filename, version, app_store_xml, iap_xml, achievements_xml, leaderboards_xml)
    metadata_filepath = File.expand_path(metadata_filename)

    metadata_contents = ''
    File.open(metadata_filepath,"r") do |f|
      metadata_contents = f.read
      f.close
    end

    altered_version = version.gsub(/\./, '\.')
    version_regex = "<version string=\"#{altered_version}\">.*<\\/version>"
    metadata_contents.sub!(/#{version_regex}/m, app_store_xml ? app_store_xml : "<version string=\"#{version}\"></version>")
    metadata_contents.force_encoding('UTF-8')

    metadata_contents.sub!(/<in_app_purchases>.*<\/in_app_purchases>/m, iap_xml ? iap_xml : '')
    metadata_contents.force_encoding('UTF-8')

    # Remove the game center section if both achievements and leaderboards are missing
    if !achievements_xml && !leaderboards_xml
      metadata_contents.sub!(/<game_center>.*<\/game_center>/m, '')
      metadata_contents.force_encoding('UTF-8')
    else
      metadata_contents.sub!(/<achievements>.*<\/achievements>/m, achievements_xml ? achievements_xml : '')
      metadata_contents.force_encoding('UTF-8')

      metadata_contents.sub!(/<leaderboards>.*<\/leaderboards>/m, leaderboards_xml ? leaderboards_xml : '')
      metadata_contents.force_encoding('UTF-8')
    end

    File.truncate(metadata_filepath, 0)
    File.open(metadata_filepath,"r+") do |f|
      f.write(metadata_contents)
      f.close
    end
  end

  def self.upload_metadata(username, password, filepath, log_name, dry_run)
    method = dry_run ? 'verify' : 'upload'
    cmd = "#{TRANSPORTER_CMD} -m #{method} -f #{filepath} -u #{username} -p \"#{password}\" &> #{log_name}"
    return system(cmd)
  end
end
