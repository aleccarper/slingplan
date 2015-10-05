require 'json'
require 'roo'
require 'spreadsheet'
require 'colorize'

module Spreadsheets

  class Parser

    def initialize(opts)
      @file_path = opts[:file_path]
      @model = opts[:model]
      @actual_columns = @model.columns.map { |col| col.name.to_sym }
      @column_map = opts[:column_map]

      @roo = Roo::Spreadsheet.open(@file_path)
    end

    def parse
      entries = []
      eof_sentinel = 0
      n_loaded = 0
      n_skipped = 0

      log_hello(@file_path, @roo)

      @roo.each_with_pagename do |sheet_name, sheet|
        next if ['National'].include? sheet_name

        log_sheet(sheet_name)

        SlackModule::API.notify_seed_upload_sheet_change(sheet_name)

        sheet.each_with_index do |row, i|
          row_index = i+1

          if row[0].nil?
            eof_sentinel += 1
            n_skipped += 1
            log_row(i)
          else
            if row_index == 1
              validate_header(sheet_name, row)
            else
              entry = {
                sheet: sheet_name,
                row: row_index,
                attrs: Hash[@column_map.keys.map.with_index { |a, j| [a, row[j]] }]
              }

              entries << entry

              eof_sentinel = 0
              n_loaded += 1
              log_row(i, entry)
            end
          end

          if eof_sentinel > 20
            eof_sentinel = 0
            break
          end
        end
      end

      log_goodbye(entries, n_loaded, n_skipped)

      entries
    end

    def validate_header(sheet, row)
      @column_map.values.each do |h|
        unless row.include? h
          raise "Invalid header values on #{sheet}.\n  Expected #{@column_map.values.join(', ')}."
        end
      end
    end

    def log_hello(file_path, roo)
      msg = "\nParsing Seed File\n"
      msg << "  file:   #{file_path}\n"
      msg << "  sheets: #{roo.sheets.length}\n\n\n"
      Rails.logger.debug msg
    end

    def log_sheet(sheet_name)
      Rails.logger.debug "\n\nParsing Sheet: '#{sheet_name.colorize(:cyan)}'\n"
    end

    def log_row(i, entry=nil)
      if entry
        Rails.logger.debug "...Row #{i}: #{JSON.pretty_generate(entry[:attrs]).colorize(:light_green)}"
      else
        Rails.logger.debug "...Row #{i}: #{'Skipping'.colorize(:yellow)}"
      end
    end

    def log_goodbye(entries, loaded, skipped)
      msg = "\n\n\nParsing Complete\n"
      msg << "  loaded:  #{loaded}\n"
      msg << "  skipped: #{skipped}\n"
      msg << "  total:   #{entries.length + skipped}\n\n\n"
      Rails.logger.debug msg
    end
  end
end
