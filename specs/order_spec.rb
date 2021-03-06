require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/order'

describe "Order Wave 1" do
  describe "#initialize" do
    it "Takes an ID and collection of products" do
      id = 1337
      order = Grocery::Order.new(id, {})

      order.must_respond_to :id
      order.id.must_equal id
      order.id.must_be_kind_of Integer

      order.must_respond_to :products
      order.products.length.must_equal 0
    end
  end

  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      sum = products.values.inject(0, :+)
      expected_total = sum + (sum * 0.075).round(2)

      order.total.must_equal expected_total
    end

    it "Returns a total of zero if there are no products" do
      order = Grocery::Order.new(1337, {})

      order.total.must_equal 0
    end
  end

  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.add_product("salad", 4.25)
      expected_count = before_count + 1
      order.products.count.must_equal expected_count
    end

    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.add_product("sandwich", 4.25)
      order.products.include?("sandwich").must_equal true
    end

    it "Returns false if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Grocery::Order.new(1337, products)
      before_total = order.total

      result = order.add_product("banana", 4.25)
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end

    it "Returns true if the product is new" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      result = order.add_product("salad", 4.25)
      result.must_equal true
    end
  end

  describe "#remove_product" do
    it "Decreases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00, "salad" => 4.25 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.remove_product("salad")
      expected_count = before_count - 1
      order.products.count.must_equal expected_count
    end

    it "Is removed from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00, "salad" => 4.25 }
      order = Grocery::Order.new(1337, products)

      order.remove_product("salad")
      order.products.include?("salad").must_equal false
    end

    it "Returns false if the product is not present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Grocery::Order.new(1337, products)
      before_total = order.total

      result = order.remove_product("salad")
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end
  end
end

describe "Order Wave 2" do
  describe "Order.all" do
    it "Returns an array of all orders" do
      # checks that .all returns array
      Grocery::Order.all.must_be_kind_of Array
    end

    it "All items are Orders" do
      # checks that all items returned by .all are Orders
      orders = Grocery::Order.all
      orders.each do |item|
        item.must_be_instance_of Grocery::Order
      end
    end

    it "Order total is correct" do
      # checks order total
      total_orders = Grocery::Order.all.length
      total_orders.must_equal 100
    end

    it "ID and product of the first order is correct" do
      # tests ID and products for first order
      first_order = [ 1, {"Slivered Almonds"=>22.88, "Wholewheat flour"=>1.93, "Grape Seed Oil"=>74.9} ]
      # check that products for first order are correct
      Grocery::Order.all[0].products.must_equal first_order[1]
      #check that id for first order is 1
      Grocery::Order.all[0].id.must_equal first_order[0]
    end

    it "ID and product of the last order is correct" do
      # tests ID and products for last order
      last_order = [ 100, {"Allspice"=>64.74, "Bran"=>14.72, "UnbleachedFlour"=>80.59} ]
      Grocery::Order.all[99].products.must_equal last_order[1]
      Grocery::Order.all[99].id.must_equal last_order[0]
    end
  end

  describe "Order.find" do
    it "Can find the first order from the CSV" do
      # ensures first order's id is correct
      Grocery::Order.find(1).id.must_equal 1
      first_order = [ 1, {"Slivered Almonds"=>22.88, "Wholewheat flour"=>1.93, "Grape Seed Oil"=>74.9} ]
      Grocery::Order.find(1).products.must_equal first_order[1]
      Grocery::Order.find(1).id.must_equal first_order[0]
    end

    it "Can find the last order from the CSV" do
      # ensures last order's id is correct
      Grocery::Order.find(100).id.must_equal 100
      last_order = [ 100, {"Allspice"=>64.74, "Bran"=>14.72, "UnbleachedFlour"=>80.59} ]
      Grocery::Order.find(100).products.must_equal last_order[1]
      Grocery::Order.find(100).id.must_equal last_order[0]
    end

    it "Raises an error for an order that doesn't exist" do
      # tells user this is an invalid id
      proc { Grocery::Order.find(101) }.must_raise ArgumentError
    end
  end
end
