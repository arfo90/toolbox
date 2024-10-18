#!/usr/bin/env ruby

require 'prawn'
require 'optparse'
require 'fileutils'

Encoding.default_external = Encoding::UTF_8
Prawn::Fonts::AFM.hide_m17n_warning = true

def process_directory(dir, pdf, options)
  Dir.glob(File.join(dir, '**', '*')).sort.each do |file|
    next if File.directory?(file)

    begin
      pdf.start_new_page
      pdf.font 'Helvetica'
      pdf.fill_color '808080'  # Gray color for the file name
      pdf.text File.basename(file), size: 10, align: :left
      pdf.move_down 10
      pdf.fill_color '000000'
      case File.extname(file).downcase
      when '.txt', '.md', '.rb', '.css', '.html', '.erb', '.ru', '.js'
        pdf.start_new_page
        content = File.read(file, encoding: 'UTF-8')
        pdf.text content
      when '.jpg', '.jpeg', '.png', '.gif'
        if options[:skip_images]
          puts "Skipping image: #{file}"
        else
          pdf.start_new_page
          pdf.image file, fit: [pdf.bounds.width, pdf.bounds.height]
        end
      when '.pdf'
        Prawn::Document.new(template: file) do |new_pdf|
          pdf.start_new_page(template: new_pdf.page.dictionary)
        end
      else
        puts "Skipping unsupported file: #{file}"
      end
    rescue StandardError => e
      puts "Error processing file #{file}: #{e.message}"
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: pdf_converter.rb [options]'
  opts.on('-d', '--directories DIR1,DIR2,DIR3', Array, 'Directories to process') do |d|
    options[:directories] = d
  end
  opts.on('-o', '--output FILE', 'Output PDF file') do |o|
    options[:output] = o
  end

  opts.on('--skip-images', 'Skip images') do |si|
    options[:skip_images] = true if si
  end
end.parse!

if options[:directories].nil? || options[:output].nil?
  puts 'Please specify input directories and output file.'
  exit
end

output_file = options[:output]
FileUtils.mkdir_p(File.dirname(output_file))

Prawn::Document.generate(output_file) do |pdf|
  pdf.font 'Helvetica'
  options[:directories].each do |dir|
    process_directory(dir, pdf, options)
  end
end

puts "PDF created successfully: #{output_file}"