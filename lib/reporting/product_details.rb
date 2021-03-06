class Reporting::ProductDetails < Aftermath::View
  class Dto < Struct.new(:product_id, :name, :sku, :category)
  end

  private
  def self.handle_product_created(event)
    product = Dto.new(event.product_id, event.name, event.sku, event.category)
    repository[event.product_id] = product
  end

  def self.handle_product_renamed(event)
    product = find(event.product_id)
    product.name = event.name
  end

  def self.handle_product_sku_modified(event)
    product = find(event.product_id)
    product.sku = event.sku
  end

  def self.handle_product_categorized(event)
    product = find(event.product_id)
    product.category = event.category
  end
end