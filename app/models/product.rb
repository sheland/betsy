class Product < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :merchant
  has_many :orderitems, dependent: :destroy
  has_many :orders, through: :orderitems

  validates :name, presence: true, uniqueness: true
  validates :cost, presence: true, numericality: { greater_than: 0 }, allow_nil: true
  validates :inventory, presence: true, numericality: { only_integer: true }
  validates :description, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :image_url, presence: true

  def self.adjust_inventory(order_items)
    order_items.each do |item|
      item.product.inventory -= item.quantity
      item.product.save
    end
  end

  def self.check_inventory(order_items)
    order_items.each do |item|
      if item.product.inventory < item.quantity
        return false
      end
    end
    return true
  end

  def average_rating
    sum = 0
    count = self.reviews.count

    if count == 0
      return 0
    else
      self.reviews.each do |review|
        sum += review.rating
      end

      return (sum * 1.0 / count).round(2)
    end
  end
end
