# frozen_string_literal: true

require "spec_helper"
require "match_table"

RSpec.describe "match_table matcher" do
  include Capybara::DSL

  before do
    Capybara.app = -> (env) {
      [200, {"Content-Type" => "text/html"}, [html]]
    }
    visit "/"
  end

  context "with exact header matching" do
    let(:html) do
      <<-HTML
        <table id="users">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>John Doe</td>
              <td>john@example.com</td>
              <td>Active</td>
            </tr>
            <tr data-table-target="row">
              <td>Jane Smith</td>
              <td>jane@example.com</td>
              <td>Inactive</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "matches when header case matches exactly" do
      expect(page).to match_table(:users).with_rows(
        {
          "Name" => "John Doe",
          "Email" => "john@example.com",
          "Status" => "Active"
        }
      )
    end

    it "fails when header case does not match exactly" do
      expect(page).not_to match_table(:users).with_rows(
        {
          "name" => "John Doe",
          "email" => "john@example.com",
          "status" => "Active"
        }
      )
    end

    it "fails when header has different capitalization" do
      expect(page).not_to match_table(:users).with_rows(
        {
          "NAME" => "John Doe",
          "EMAIL" => "john@example.com",
          "STATUS" => "Active"
        }
      )
    end

    it "matches exact headers with spaces" do
      expect(page).to match_table(:users).with_rows(
        {
          "Name" => "John Doe",
          "Email" => "john@example.com",
          "Status" => "Active"
        }
      )
    end
  end

  context "with partial header matching (old behavior)" do
    let(:html) do
      <<-HTML
        <table id="products">
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Price</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>Widget</td>
              <td>$10.00</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "does not match partial headers anymore" do
      expect(page).not_to match_table(:products).with_rows(
        {
          "Product" => "Widget",
          "Price" => "$10.00"
        }
      )
    end

    it "requires exact header match" do
      expect(page).to match_table(:products).with_rows(
        {
          "Product Name" => "Widget",
          "Price" => "$10.00"
        }
      )
    end
  end

  context "with multiple rows and exact order" do
    let(:html) do
      <<-HTML
        <table id="orders">
          <thead>
            <tr>
              <th>ID</th>
              <th>Customer</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>001</td>
              <td>Alice</td>
              <td>$50.00</td>
            </tr>
            <tr data-table-target="row">
              <td>002</td>
              <td>Bob</td>
              <td>$75.00</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "matches with exact headers in exact order" do
      expect(page).to match_table(:orders).with_exact_rows(
        {"ID" => "001", "Customer" => "Alice", "Total" => "$50.00"},
        {"ID" => "002", "Customer" => "Bob", "Total" => "$75.00"}
      )
    end

    it "fails with mismatched header case" do
      expect(page).not_to match_table(:orders).with_exact_rows(
        {"id" => "001", "customer" => "Alice", "total" => "$50.00"}
      )
    end
  end

  context "with sortable headers (arrow icons)" do
    let(:html) do
      <<-HTML
        <table id="sortable">
          <thead>
            <tr>
              <th>Name arrow_drop_down</th>
              <th>Age   arrow_drop_up  </th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>Charlie</td>
              <td>30</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "normalizes headers by removing arrow icons and extra spaces" do
      expect(page).to match_table(:sortable).with_rows(
        {"Name" => "Charlie", "Age" => "30"}
      )
    end
  end

  context "with data-role attribute in headers" do
    let(:html) do
      <<-HTML
        <table id="special">
          <thead>
            <tr>
              <th><span data-role="header-text">Item</span></th>
              <th>Count</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>Apple</td>
              <td>5</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "extracts header text from data-role elements when th is empty" do
      expect(page).to match_table(:special).with_rows(
        {"Item" => "Apple", "Count" => "5"}
      )
    end
  end

  context "with accordion content rows" do
    let(:html) do
      <<-HTML
        <table id="expandable">
          <thead>
            <tr>
              <th>Name</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>David</td>
              <td>View</td>
            </tr>
            <tr data-accordion-content>
              <td colspan="2">
                <div>Expanded content here</div>
              </td>
            </tr>
            <tr data-table-target="row">
              <td>Eve</td>
              <td>Edit</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "excludes rows inside accordion content" do
      expect(page).to match_table(:expandable).with_exact_rows(
        {"Name" => "David", "Action" => "View"},
        {"Name" => "Eve", "Action" => "Edit"}
      )
    end
  end

  context "with tbody.contents class" do
    let(:html) do
      <<-HTML
        <table id="filtered">
          <thead>
            <tr>
              <th>Type</th>
              <th>Value</th>
            </tr>
          </thead>
          <tbody class="contents">
            <tr data-table-target="row">
              <td>Should be ignored</td>
              <td>Contents class</td>
            </tr>
          </tbody>
          <tbody>
            <tr data-table-target="row">
              <td>Visible</td>
              <td>Normal tbody</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "only matches rows in tbody without 'contents' class" do
      expect(page).to match_table(:filtered).with_exact_rows(
        {"Type" => "Visible", "Value" => "Normal tbody"}
      )
    end
  end

  context "with string table identifier" do
    let(:html) do
      <<-HTML
        <table>
          <caption>My Table</caption>
          <thead>
            <tr>
              <th>Column</th>
            </tr>
          </thead>
          <tbody>
            <tr data-table-target="row">
              <td>Data</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "finds table by caption text (string identifier)" do
      expect(page).to match_table("My Table").with_rows(
        {"Column" => "Data"}
      )
    end
  end

  context "with rows that lack data-table-target attribute" do
    let(:html) do
      <<-HTML
        <table id="targettest">
          <thead>
            <tr>
              <th>Field</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Should not match</td>
            </tr>
            <tr data-table-target="row">
              <td>Should match</td>
            </tr>
          </tbody>
        </table>
      HTML
    end

    it "only matches rows with data-table-target='row' attribute" do
      expect(page).to match_table(:targettest).with_exact_rows(
        {"Field" => "Should match"}
      )
    end
  end
end
