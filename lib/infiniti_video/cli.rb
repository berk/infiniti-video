require 'thor'
require 'translit'

module InfinitiVideo
  class Cli < Thor

    include Thor::Actions

    class << self
      def source_root
        File.expand_path('../../',__FILE__)
      end
    end

    desc 'list', 'List files in the source folder (Shortcut: l)'
    method_option :source,  :aliases => '-s',  :banner => 'source folder', :type => :string, :required => true
    map 'l' => :list
    def list
      source = validate_folder(options[:source])
      count = 0

      table = []
      table << ['File Name', 'Type', 'Size']
      table << ['---------', '----', '----']

      Dir.entries(source).each do |file|
        path = "#{source}/#{file}"
        next if File.directory?(path)
        ext = file.split('.').last
        next unless valid_video?(ext)
        file_size = (File.size(path).to_f / 2**20).round(2)
        table << [file, ext.upcase, "#{file_size} Mb"]
        count += 1
      end

      puts "\nFound #{count} video files in #{source} \n\n"
      print_table(table)
      puts "\n"
    end

    desc 'convert', 'Converts source videos to target format (Shortcut: c)'
    method_option :source,  :aliases => '-s', :banner => 'source folder', :type => :string, :required => true
    method_option :target,  :aliases => '-t', :banner => 'target folder', :type => :string, :required => true
    method_option :archive, :aliases => '-a', :banner => 'archive folder', :type => :string, :required => false
    map 'c' => :convert
    def convert
      source = validate_folder(options[:source])
      target = validate_folder(options[:target])
      archive = options[:archive] ? validate_folder(options[:archive]) : nil

      count = 0
      Dir.entries(source).each do |file|
        input = File.join(source, file)
        next if File.directory?(input)
        ext = file.split('.').last
        next unless valid_video?(ext)

        count += 1
        output = File.join(target, file.gsub(ext, 'avi'))

        puts "\n*****************************************************"
        puts "Converting \"#{input}\" to \"#{output}\" ..."
        puts "*****************************************************"

        if File.exist?(output)
          puts 'The file has already been processed, skipping...'
        else
          convert_file(input, output)
        end

        if archive
          puts "Archiving #{input} to #{archive}..."
          FileUtils.move(input, archive)
        end
      end
    end

    desc 'translit', 'Renames files from Cyrilic to English'
    method_option :source,  :aliases => '-s', :banner => 'source folder', :type => :string, :required => true
    map 't' => :translit
    def translit
      Dir.entries(source).each do |file|
        file_name = Translit.convert(file).downcase
        file_name = file_name.strip.gsub(/\s+/, ' ')
        from = "#{file}"
        to = File.join(source, file_name)
        next if from == to

        puts "Renaming from \"#{from}\" to \"#{to}\"..."
        File.rename(from, to)
      end
    end

  private

    def validate_folder(folder)
      unless File.exist?(folder)
        puts "Folder #{folder} not found"
        exit
      end

      unless File.directory?(folder)
        puts "#{folder} is not a folder"
        exit
      end

      folder
    end

    def valid_video?(ext)
      %w(avi mp4 mkv).include?(ext.downcase)
    end

    def convert_file(source, target)
      cmd = "ffmpeg -y -i \"#{source}\" -c:v mpeg4 -vtag DIVX -q:v 6 -filter:v scale=720:-1 -r 30 -c:a libmp3lame -ar 48000 -ab 128k -ac 2 -async 48000 -threads 8 \"#{target}\""
      puts cmd
      system(cmd)
    end

  end
end
