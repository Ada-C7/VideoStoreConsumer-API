class CustomersController < ApplicationController
  SORT_FIELDS = %w(name registered_at postal_code)

  before_action :parse_query_args

  def index
    if @sort
      data = Customer.all.order(@sort)
    else
      data = Customer.all
    end

    data = data.paginate(page: params[:p], per_page: params[:n])

    render json: data.as_json(
    only: [:id, :name, :registered_at, :address, :city, :state, :postal_code, :phone, :account_credit],
    methods: [:movies_checked_out_count]
    )
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.create(customer_params)
  end

  def update
    @customer = Customer.find_by(id: params[:id])
    if @customer.nil?
      head :not_found
    else
      @customer.update_attributes(customer_params)
      redirect_to customer_path
    end
  end

  def edit
    @customer = Customer.find_by(id: params[:id])
  end

  def destroy
    @customer = Customer.find_by(id: params[:id])
    @customer.destroy
    redirect_to customers_path
  end

  private
  def parse_query_args
    errors = {}
    @sort = params[:sort]
    if @sort and not SORT_FIELDS.include? @sort
      errors[:sort] = ["Invalid sort field '#{@sort}'"]
    end

    unless errors.empty?
      render status: :bad_request, json: { errors: errors }
    end
  end

  def customer_params
    return params.require(:customer).permit(:name, :address, :city, :state, :postal_code, :phone, :account_credit)
  end

end
