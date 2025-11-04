class TxsController < ApplicationController
  before_action :set_tx, only: %i[ show edit update destroy ]

  # GET /txs or /txs.json
  def index
    @txs = Tx.all
  end

  # GET /txs/1 or /txs/1.json
  def show
  end

  # GET /txs/new
  def new
    @tx = Tx.new
  end

  # GET /txs/1/edit
  def edit
  end

  # POST /txs or /txs.json
  def create
    @tx = Tx.new(tx_params)

    respond_to do |format|
      if @tx.save
        format.html { redirect_to @tx, notice: "Tx was successfully created." }
        format.json { render :show, status: :created, location: @tx }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tx.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /txs/1 or /txs/1.json
  def update
    respond_to do |format|
      if @tx.update(tx_params)
        format.html { redirect_to @tx, notice: "Tx was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @tx }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tx.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /txs/1 or /txs/1.json
  def destroy
    @tx.destroy!

    respond_to do |format|
      format.html { redirect_to txs_path, notice: "Tx was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tx
      @tx = Tx.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tx_params
      params.expect(tx: [ :date, :amount, :currency, :description ])
    end
end
