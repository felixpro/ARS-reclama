class CustomersController < ApplicationController
  include ActionController::MimeResponds
  before_action :set_customer, only: [:show, :edit, :update, :destroy]


  def ars
    @customer = Customer.new
  end

  def cenasa
    @customer = Customer.new
  end

  def naseguro
    @customer = Customer.new
  end

  # GET /customers
  # GET /customers.json
  def index

    if params[:q]
      search_term = params[:q]
      @customers = Customer.search(search_term)
      # return our filtered list here
    else
      @customers = Customer.all.order('created_at DESC').limit(15);
    end


    @customer_total = Customer.all.order('created_at DESC').limit(15);
    @customerNew = Customer.new
    @reclamations = Reclamation.all.order('created_at DESC').limit(15);
    @reclamation_number = 0;
    @identifier = 0;


    ######### Detect when a reclamation should be in the draft
    @draftreclamations = @reclamations.where(authNum: nil);
    ######### month
    @monthCustomer      = @customer_total.where('created_at >= ?', 1.month.ago).count
    @monthreclamations  = @reclamations.where('created_at >= ?', 1.month.ago).count
    @reclam_month       = @reclamations.where('created_at >= ?', 1.month.ago)
    @month_therapies    = 0;
    @reclam_month .each do |reclamation|
      reclamation.therapiesNum.to_i.times do | num |
        @month_therapies  = @month_therapies  + 1;
      end
    end

    ######### week
    @weekCustomer      = @customer_total.where('created_at >= ?', 1.week.ago).count
    @weekreclamations  = @reclamations.where('created_at >= ?', 1.week.ago).count
    @reclam_week       = @reclamations.where('created_at >= ?', 1.week.ago)
    @week_therapies    = 0;
    @reclam_week.each do |reclamation|
      reclamation.therapiesNum.to_i.times do | num |
        @week_therapies = @week_therapies + 1;
      end
    end


    ######### year
    @yearCustomer      = @customer_total.where('created_at >= ?', 1.year.ago).count
    @yearreclamations  = @reclamations.where('created_at >= ?', 1.year.ago).count
    @reclam_year       = @reclamations.where('created_at >= ?', 1.year.ago)
    @year_therapies    = 0;
    @reclam_year.each do |reclamation|
      reclamation.therapiesNum.to_i.times do | num |
        @year_therapies = @year_therapies + 1;
      end
    end

    # if the reclamation doens't has an authNum, it is not a reclamation
    @reclamations .each do |reclamation|
      if reclamation.authNum.blank?
        @weekreclamations =  @weekreclamations - 1
        @yearreclamations =  @yearreclamations - 1
        @monthreclamations =  @monthreclamations - 1


      end
    end

  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = Customer.find(params[:id])
    @appointments = @customer.appointment.order('created_at DESC');
    @historiales =  @customer.historial.order('created_at DESC');
    @procedures =  @customer.procedure.order('created_at DESC');

    @identifierHistorial = 0;
    @service = @customer.service.order('created_at DESC');
    @reclamation = @customer.reclamation.order('created_at DESC');
    @reclamation_actual = @customer.reclamation

    @historialReclamation = @reclamation.where(ensureReclam:"identifier")
    if @reclamation.count > 0
      @lastReclamation = Reclamation.last.authNum
      @lastReclamInsurance = Reclamation.last.doctor

      @lastDiagnostic = @reclamation_actual.last.diagnostic
      @lastAuthNum = @reclamation_actual.last.authNum


    else
      @lastDiagnostic = ""
    end

    @identifier = 0;
    @therapiequantity = 0;
     @reclamation.each do |reclamation|
      reclamation.therapiesNum.to_i.times do | num |
        @therapiequantity = @therapiequantity + 1;
      end
     end
     @total_therapies = @therapiequantity.to_i


    @therapies_num_customer = @customer.therapies_num;
    # to avoid error using the times, when it is nill
    if @therapies_num_customer === nil
      @therapies_num_customer = 0
    else
      @therapies_num_customer = @customer.therapies_num;

    end

  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])

  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    @customer.image.attach(params[:customer][:image])


    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer}
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { redirect_to(@customer,  warning: 'Cliente ya existe ') }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json


  def update
    @customer = Customer.find(params[:id])
    respond_to do |format|
      if @customer.update_attributes(customer_params)
        format.html { redirect_to(@customer,  success: 'Guardado Correctamente') }
        format.json { respond_with_bip(@customer) }
      else
        format.html { redirect_to(@customer,  warning: 'Cliente ya existe ') }

      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, success: 'Cliente eliminado correctamente' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.permit(:term)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:name, :phone, :cell, :email, :affiliate_number, :img, :age, :doc, :sector, :city, :gender, :doc_type, :autorization_number, :therapies, :adress, :insurance, :contractNum, :diagnostic, :therapies_num, :total_therapies)
    end
end