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
end
