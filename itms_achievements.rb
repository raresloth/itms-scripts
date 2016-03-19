require 'CSV'
require_relative 'itms_utils.rb'

class ITMSAchievements

  def self.locale_string(locale_name, title, before_description, after_description, image_name)
    image_data_string = ITMSUtils.image_data_string(@@input_images_dir, image_name)
    @@images_used << "#{@@input_images_dir}/#{image_name}"

    output = "<locale name=\"#{locale_name}\">"
    output += "<title>#{title}</title>"
    output += "<before_earned_description>#{before_description}</before_earned_description>"
    output += "<after_earned_description>#{after_description}</after_earned_description>"
    output += "<achievement_after_earned_image>#{image_data_string}</achievement_after_earned_image>"
    output += "</locale>"
  end

  def self.locale_strings_for_id(id)
    locale_row_data = @@locale_row_data_by_id[id]

    locale_strings = ''
    locale_row_data.each do |row_data|
      locale_name = row_data[1]
      title = row_data[2]
      before_description = row_data[3]
      after_description = row_data[4]
      image_name = row_data[5]
      locale_strings += locale_string(locale_name, title, before_description, after_description, image_name)
    end

    locale_strings
  end

  def self.achievement(position, row_data)
    id = row_data[0]
    reference_name = row_data[1]
    points = row_data[2].to_i
    hidden = row_data[3].downcase

    achievement = "<achievement position=\"#{position}\">"
    achievement += "<achievement_id>#{id}</achievement_id>"
    achievement += "<reference_name>#{reference_name}</reference_name>"
    achievement += "<points>#{points}</points>"
    achievement += "<hidden>#{hidden}</hidden>"
    achievement += "<locales>#{locale_strings_for_id(id)}</locales>"
    achievement += "</achievement>"
  end

  def self.achievements_xml(input_metadata_filename, input_locale_filename, input_images_directory)
    @@input_images_dir = input_images_directory
    @@images_used = Set.new

    input_locales = CSV.read(input_locale_filename)
    input_locales.delete_at(0)
    @@locale_row_data_by_id = ITMSUtils.locale_row_data_by_id(input_locales)

    input_metadata = CSV.read(input_metadata_filename)
    input_metadata.delete_at(0)
    puts "[ITMS] Found #{input_metadata.count} achievements"

    output = '<achievements>'
    position = 1
    input_metadata.each do |row_data|
      output += achievement(position, row_data)
      position += 1
    end
    output += "</achievements>"

    return output, @@images_used
  end

end