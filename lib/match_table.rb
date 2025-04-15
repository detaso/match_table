# frozen_string_literal: true

require_relative "match_table/version"
require "rspec/expectations"
require "capybara"

module MatchTable
end

RSpec::Matchers.define :match_table do |table|
  match do |page|
    @table = table

    @found_table = false
    expect(page).to have_table @table
    @found_table = true

    expected_headers = @expected_rows.first.keys

    same_headers =
      @expected_rows.all? do |row|
        row.keys == expected_headers
      end

    raise ArgumentError, "all rows must have the same headers" unless same_headers

    begin
      # We'll rerun this block until our expectations are met or we time out.
      synchronize do
        @failures = []
        find_elements_on_page

        header_positions =
          expected_headers.each_with_object({}) do |header, hash|
            position = @actual_headers.find_index { |actual_header| actual_header.start_with?(header) }
            unless position.nil?
              hash[header] = position
            end
          end

        matched_rows = []
        @actual_rows.each do |actual_row|
          matched_rows << match_row(header_positions:, actual_row:)
        end

        @actual = matched_rows
        @expected_as_array = Array(@expected_rows)

        # Grab the failures from these expectations so we can use their failure messages
        RSpec::Support.with_failure_notifier(append_to_failures_array_notifier) do
          case @mode
          when :exact
            expect(actual).to eq(expected_as_array)
          when :include
            expect(actual).to include(*expected_as_array)
          end
        end

        raise Capybara::ExpectationNotMet unless @failures.empty?
      end
    rescue Capybara::ExpectationNotMet
      false
    end

    @failures.empty?
  end

  # Match the table exactly with the provided rows in order.
  chain :with_exact_rows do |*rows|
    @mode = :exact
    @expected_rows = rows
  end

  # Ensure the table includes the provided rows, but not necessarily in order.
  chain :with_rows do |*rows|
    @mode = :include
    @expected_rows = rows
  end

  failure_message do |page|
    if !@found_table
      "unable to find table \"#{table}\" on page"
    else
      <<~MESSAGE
        found table "#{table}" on page, with headers:
        #{@actual_headers}
        but rows did not match expected values:
        #{@failures.map(&:message).join("\n")}
      MESSAGE
    end
  end

  def synchronize
    Capybara.current_session.document.synchronize do
      yield
    end
  end

  def find_table(identifier)
    if identifier.is_a?(Symbol)
      find_by_id(identifier)
    else
      find(:table, identifier)
    end
  end

  def find_elements_on_page
    table = find_table(@table)

    @actual_headers =
      table.find("thead").all("th").map(&:text)

    @actual_rows = []

    rows = table.find("tbody:not(.contents)").all("tr[data-table-target='row']:not([data-accordion-content] table tr)").presence ||
      table.find("tbody:not(.contents)").all("tr[data-table-target='row']")

    rows.each do |row|
      cells = row.all("td")
      @actual_rows << cells.map(&:text)
    end
  end

  def match_row(header_positions:, actual_row:)
    header_positions.each_with_object({}) do |(header, position), matched_row|
      matched_row[header] = actual_row[position]
    end
  end

  def append_to_failures_array_notifier
    lambda { |failure, _opts| @failures << failure }
  end
end
