# frozen_string_literal: true

namespace :ofx do
  desc "Import and display OFX file transactions"
  task :import, [ :file_path ] => :environment do |_t, args|
    file_path = args[:file_path]

    unless file_path
      puts "Usage: bin/rails ofx:import[path/to/file.ofx]"
      puts "\nExample files:"
      puts "  bin/rails ofx:import['lib/ANZ CC.ofx']"
      puts "  bin/rails ofx:import['lib/ANZ CQ.ofx']"
      exit 1
    end

    unless File.exist?(file_path)
      puts "Error: File not found: #{file_path}"
      exit 1
    end

    importer = OfxImporterService.new(file_path)
    importer.parse
    importer.print_transactions
  end

  desc "Import both example OFX files"
  task import_examples: :environment do
    [ "lib/real/ANZ CC.ofx", "lib/real/ANZ CQ.ofx" ].each do |file_path|
      if File.exist?(file_path)
        importer = OfxImporterService.new(file_path)
        importer.parse
        importer.print_transactions
      else
        puts "Warning: File not found: #{file_path}"
      end
    end
  end
end
