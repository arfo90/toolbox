#!/usr/bin/env ruby

require 'prawn'
require 'optparse'
require 'fileutils'

def process_directory(dir, pdf)
  Dir.glob(File.join(dir, '**', '*')).sort.each do |file|
    next if File.directory?(file)
    
    begin
      pdf.start_new_page
      pdf.fill_color '808080'  # Gray color for the file name
      pdf.text File.basename(file), size: 10, align: :left
      pdf.move_down 10
      pdf.fill_color '000000'  # Reset to black for main content

      case File.extname(file).downcase
      when '.txt', '.md'
        pdf.text File.read(file)
      when '.jpg', '.jpeg', '.png', '.gif'
        pdf.image file, fit: [pdf.bounds.width, pdf.bounds.height - 20]  # Adjust height to account for filename
      when '.pdf'
        Prawn::Document.new(template: file) do |new_pdf|
          pdf.go_to_page(pdf.page_count)
          pdf.start_new_page(template: new_pdf.page.dictionary)
        end
      else
        puts "Skipping unsupported file: #{file}"
      end
    rescue => e
      puts "Error processing file #{file}: #{e.message}"
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: pdf_converter.rb [options]"

  opts.on("-d", "--directories DIR1,DIR2,DIR3", Array, "Directories to process") do |d|
    options[:directories] = d
  end

  opts.on("-o", "--output FILE", "Output PDF file") do |o|
    options[:output] = o
  end
end.parse!

if options[:directories].nil? || options[:output].nil?
  puts "Please specify input directories and output file."
  exit
end

output_file = options[:output]
FileUtils.mkdir_p(File.dirname(output_file))

Prawn::Document.generate(output_file) do |pdf|
  options[:directories].each do |dir|
    process_directory(dir, pdf)
  end
end

puts "PDF created successfully: #{output_file}"
