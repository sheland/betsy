class OrderitemsController < ApplicationController
  before_action :find_orderitem, only: [:update, :destroy]
  skip_before_action :require_login, only: [:create, :update, :destroy]

  def create
    @orderitem = Orderitem.new(orderitem_params)

    if session[:order_id] == nil
      @order = Order.create
      session[:order_id] = @order.id
    else
      @order = Order.find_by(id: session[:order_id])
    end

    if Orderitem.already_in_cart?(@orderitem, @order)
      flash[:status] = :failure
      flash[:result_text] = "This item already exists in your cart."
      redirect_to order_path(session[:order_id])
    else
      @orderitem.order_id = @order.id
      if @orderitem.save
        redirect_to order_path(@order.id)
      else
        flash[:status] = :failure
        flash[:result_text] = "Could not save"
        flash[:messages] = @orderitem.errors.messages
        render "layouts/servererror", status: :internal_server_error
      end
    end
  end

  def update
    if @orderitem.update(orderitem_params)
      redirect_back(fallback_location: root_path)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update your quantity"
      flash.now[:messages] = @orderitem.errors.messages
      render "layouts/servererror", status: :internal_server_error
    end
  end

  def index
    if params[:merchant_id]
      @merchant = Merchant.find_by(id: params[:merchant_id])
      @orderitems = @merchant.orderitems
    end
  end

  def show
    if params[:merchant_id]
      @merchant = Merchant.find_by(id: params[:merchant_id])
      @orderitems = Merchant.items_by_orderid(@merchant.orderitems)

      @orderitem = @orderitems[params[:id]]
      @order = @orderitem.order(:name)
    end
  end

  # Test Done
  def destroy
    @orderitem.destroy
    redirect_back(fallback_location: root_path)
  end

  private
  def orderitem_params
    params.permit(:quantity, :product_id)
  end

  def find_orderitem
    @orderitem = Orderitem.find_by(id: params[:id].to_i)

    if @orderitem.nil?
      render "layouts/notfound", status: :not_found
    end
  end
end
