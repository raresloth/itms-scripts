require 'CSV'
require_relative 'itms_utils.rb'

class ITMSLeaderboards

  def self.locale_string(locale_name, title, formatter_type, image_name)
    image_data_string = ITMSUtils.image_data_string(@@input_images_dir, image_name)
    @@images_used << "#{@@input_images_dir}/#{image_name}"

    output = "<locale name=\"#{locale_name}\">"
    output += "<title>#{title}</title>"
    output += "<formatter_type>#{formatter_type}</formatter_type>"
    output += "<leaderboard_image>#{image_data_string}</leaderboard_image>"
    output += "</locale>"
    output
  end

  def self.locale_strings_for_id(id)
    locale_row_data = @@locale_row_data_by_id[id]

    locale_strings = ''
    locale_row_data.each do |row_data|
      locale_name = row_data[1]
      title = row_data[2]
      formatter_type = row_data[3]
      image_name = row_data[4]
      locale_strings += locale_string(locale_name, title, formatter_type, image_name)
    end

    locale_strings
  end

  def self.leaderboard(position, row_data)
    id = row_data[0]
    reference_name = row_data[1]
    sort_ascending = row_data[2].downcase

    default_param = position == 1 ? ' default="true"' : ''
    leaderboard = "<leaderboard position=\"#{position}\"#{default_param}>"
    leaderboard += "<leaderboard_id>#{id}</leaderboard_id>"
    leaderboard += "<reference_name>#{reference_name}</reference_name>"
    leaderboard += "<sort_ascending>#{sort_ascending}</sort_ascending>"
    leaderboard += "<locales>#{locale_strings_for_id(id)}</locales>"
    leaderboard += "</leaderboard>"
    leaderboard
  end

  def self.leaderboards_xml(input_metadata_filename, input_locale_filename, input_images_directory)
    @@input_images_dir = File.expand_path(input_images_directory)
    @@images_used = Set.new

    input_locales = CSV.read(input_locale_filename)
    input_locales.delete_at(0)
    @@locale_row_data_by_id = ITMSUtils.locale_row_data_by_id(input_locales)

    input_metadata = CSV.read(input_metadata_filename)
    input_metadata.delete_at(0)
    puts "[ITMS] Found #{input_metadata.count} leaderboards"

    output = '<leaderboards>'
    position = 1
    input_metadata.each do |row_data|
      output += leaderboard(position, row_data)
      position += 1
    end
    output += "</leaderboards>"

    return output, @@images_used
  end

end