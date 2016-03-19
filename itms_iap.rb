require 'CSV'
require_relative 'itms_utils.rb'

class ITMSIAP

  def self.locale_string(locale_name, title, description)
    output = "<locale name=\"#{locale_name}\">"
    output += "<title>#{title}</title>"
    output += "<description>#{description}</description>"
    output += "</locale>"
    output
  end

  def self.locale_strings_for_id(id)
    locale_row_data = @@locale_row_data_by_id[id]

    locale_strings = ''
    locale_row_data.each do |row_data|
      locale_name = row_data[1]
      title = row_data[2]
      description = row_data[3]
      locale_strings += locale_string(locale_name, title, description)
    end

    locale_strings
  end

  def self.iap(row_data)
    id = row_data[0]
    reference_name = row_data[1]
    type = row_data[2]
    cleared_for_sale = row_data[3].downcase
    price_tier = row_data[4].to_i
    image_name = row_data[5]

    image_data_string = ITMSUtils.image_data_string(@@input_images_dir, image_name)
    @@images_used << "#{@@input_images_dir}/#{image_name}"

    output = "<in_app_purchase>"
    output += "<product_id>#{id}</product_id>"
    output += "<reference_name>#{reference_name}</reference_name>"
    output += "<type>#{type}</type>"
    output += "<products><product>\
    <cleared_for_sale>#{cleared_for_sale}</cleared_for_sale>\
    <intervals>\
      <interval>\
        <start_date>#{Time.now.strftime("%Y-%m-%d")}</start_date>\
        <wholesale_price_tier>#{price_tier}</wholesale_price_tier>\
      </interval>\
    </intervals>\
  </product></products>"
    output += "<locales>#{locale_strings_for_id(id)}</locales>"
    output += "<review_screenshot>#{image_data_string}</review_screenshot>"
    output += "</in_app_purchase>"
  end

  def self.iap_xml(input_metadata_filename, input_locale_filename, input_images_directory)
    @@input_images_dir = File.expand_path(input_images_directory)
    @@images_used = Set.new

    input_locales = CSV.read(input_locale_filename)
    input_locales.delete_at(0)
    @@locale_row_data_by_id = ITMSUtils.locale_row_data_by_id(input_locales)

    input_metadata = CSV.read(input_metadata_filename)
    input_metadata.delete_at(0)
    puts "[ITMS] Found #{input_metadata.count} in app purchases"

    output = '<in_app_purchases>'
    input_metadata.each do |row_data|
      output += iap(row_data)
    end
    output += "</in_app_purchases>"

    return output, @@images_used
  end

end