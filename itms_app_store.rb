require 'CSV'
require_relative 'itms_utils.rb'

class ITMSAppStore

  def self.description_string(locale_name)
    filename = "#{@@locales_directory}/#{locale_name}/app_store_description.txt"
    contents = File.open(filename, 'rb').read
    contents.force_encoding('UTF-8')
    contents
  end

  def self.keywords(raw_input)
    keywords_xml = ''
    keywords = raw_input.split(',')
    keywords.each do |keyword|
      keywords_xml += "<keyword>#{keyword.strip}</keyword>"
    end
    keywords_xml
  end

  def self.software_screenshots(locale_name)
    screenshots_xml = ''

    display_targets = ['iOS-3.5-in', 'iOS-4-in', 'iOS-4.7-in', 'iOS-5.5-in', 'iOS-iPad', 'iOS-iPad-Pro']

    display_targets.each_with_index do |display_target, display_target_index|
      5.times do |i|
        image_name = "#{@@base_image_names[display_target_index]}_#{i.to_s.rjust(2, '0')}.png"
        localized_image_name = "#{locale_name}_#{image_name}"
        localized_directory = "#{@@locales_directory}/#{locale_name}"

        image_data_string = ITMSUtils.image_data_string(localized_directory, localized_image_name)
        @@images_used << "#{localized_directory}/#{localized_image_name}"

        screenshots_xml += "<software_screenshot display_target=\"#{display_target}\" position=\"#{i + 1}\">"
        screenshots_xml += image_data_string
        screenshots_xml += "</software_screenshot>"
      end
    end

    screenshots_xml
  end

  def self.locale_string(row_data)
    locale_name = row_data[0]
    output = "<locale name=\"#{locale_name}\">"
    output += "<title>#{row_data[1]}</title>"
    output += "<description>#{description_string(locale_name)}</description>"
    output += "<keywords>#{keywords(row_data[2])}</keywords>"
    output += "<software_url>#{row_data[3]}</software_url>"
    output += "<privacy_url>#{row_data[4]}</privacy_url>"
    output += "<support_url>#{row_data[5]}</support_url>"
    if @@base_image_names
      output += "<software_screenshots>#{software_screenshots(locale_name)}</software_screenshots>"
    end
    output += "</locale>"
    output
  end

  def self.app_store_xml(version, input_locale_filename, locales_directory, base_image_names)
    @@locales_directory = locales_directory
    @@base_image_names = base_image_names
    @@images_used = Set.new

    input_locales = CSV.read(input_locale_filename, { :col_sep => "\t" })
    input_locales.delete_at(0)
    puts "[ITMS] Found #{input_locales.count} app store languages"

    output = "<version string=\"#{version}\"><locales>"
    input_locales.each do |row_data|
      output += locale_string(row_data)
    end
    output += "</locales></version>"

    return output, @@images_used
  end

end