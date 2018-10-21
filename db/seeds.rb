require 'csv'

MERCHANT_FILE = Rails.root.join('db', 'seed_data', 'merchant.csv')
puts "Loading raw merchant data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  merchant = Merchant.new
  merchant.id = row['id'].to_i
  merchant.name = row['name']
  merchant.email = row['email']
  merchant.uid = row['uid']
  merchant.provider = row['provider']
  successful = merchant.save
  if !successful
    merchant_failures << merchant
    puts "\n"
    puts "Failed to save merchant id: #{merchant.id}"
    puts "Errors: #{merchant.errors.full_messages}"
    puts "\n"
  else
    puts "Created merchant: #{merchant.inspect}"
  end
end

puts "Added #{Merchant.count} merchant records"
puts "#{merchant_failures.length} merchants failed to save"

PRODUCT_FILE = Rails.root.join('db', 'seed_data', 'product.csv')
puts "Loading raw product data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.id = row['id'].to_i
  product.name = row['name']
  product.cost = row['cost'].to_f
  product.merchant_id = row['merchant_id'].to_i
  product.inventory = row['inventory'].to_i
  product.description = row['description']
  product.image_url = row['image_url']
  successful = product.save
  if !successful
    product_failures << product
    puts "\n"
    puts "Failed to save product id: #{product.id}"
    puts "#{product.inspect}"
    puts "Errors: #{product.errors.full_messages}"
    puts "\n"
  else
    puts "Created product: #{product.inspect}"
  end
end

puts "Added #{Product.count} product records"
puts "#{product_failures.length} products failed to save"

puts "Manually resetting PK sequence on each table"
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

puts "done"
