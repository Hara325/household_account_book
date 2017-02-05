class HouseholdsController < ApplicationController
  before_action :set_household, only: [:show, :edit, :update, :destroy]

  # GET /households
  # GET /households.json
  def index
    if params[:title].blank?
      @title = "年間一覧"
    elsif params[:title] == '年間一覧'
      @title = "月間一覧"
    elsif params[:title] == '月間一覧'
      @title = "詳細"
    else
      @title = "年間一覧"
    end

    #TODO modelに記述
    if @title == '年間一覧'
      @disp_unit = DISP_YEAR
      @category_sum_hash = {}

      #現在の年から年過去10年分 を取得
      @year = Date.today.year
      DISP_YEAR.times do |i|
        category_sum_hash = {}
        Category.all.order(:id).each do |category|
          households = Household.where(["category_id = ? and use_date > ? and use_date < ?",
            category.id, (@year - i - 1).to_s + '/12/31', (@year - i + 1).to_s + '/01/01'])
           category_sum_hash[category.id] = households.sum(:cost)
        end
        @category_sum_hash[@year - i] = category_sum_hash
      end
    elsif @title == '月間一覧'
      @disp_unit = 12
      @year = params[:year]
      @category_sum_hash = {}

      ##選択した年の月間一覧を取得
      12.times do |i|
        from_ym = @year + '/' + i.to_s + '/' + Date.new(@year.to_i, i, -1).day.to_s unless i == 0
        from_ym = (@year.to_i - 1).to_s + '/12/31' if i == 0

        to_ym = @year + '/' + (i + 1 + 1).to_s unless i + 1 == 12
        to_ym = (@year.to_i + 1).to_s + '/1' if i + 1 == 12

        category_sum_hash = {}
        Category.all.order(:id).each do |category|
          households = Household.where(["category_id = ? and use_date > ? and use_date < ?",
             category.id, from_ym, to_ym + '/01'])
          category_sum_hash[category.id] = households.sum(:cost)
        end
        @category_sum_hash[i + 1] = category_sum_hash
      end
    elsif @title == '詳細'
      year = params[:month].to_i == 1 ? params[:year].to_i - 1 : params[:year].to_i
      month = params[:month].to_i == 1 ? 12 : params[:month].to_i - 1
      from_ym = Date.new(year, month, -1)

      year = params[:month].to_i == 12 ? params[:year].to_i + 1 : params[:year].to_i
      month = params[:month].to_i == 12 ? 1 : params[:month].to_i + 1
      to_ym = Date.new(year, month, 1)

      @households = Household.where(["use_date > ? and use_date < ?", from_ym, to_ym]).order(:use_date)
      @category_hash = {}
      Category.all.each do |category|
        @category_hash[category.id] = category.category_name
      end
      
    end
  end

  # GET /households/1
  # GET /households/1.json
  def show
  end

  # GET /households/new
  def new
    @household = Household.new
    @category = Category.all
  end

  # GET /households/1/edit
  def edit
    @category = Category.all
  end

  # POST /households
  # POST /households.json
  def create
    @household = Household.new(household_params)
    @category = Category.all

    if @household.save
      flash[:notice] = '登録しました。'
      redirect_to action: :new
    else
      flash[:notice] = '失敗しました。'
      render action: :new
    end
  end

  # PATCH/PUT /households/1
  # PATCH/PUT /households/1.json
  def update
    if @household.update(household_params)
      flash[:notice] = '登録しました。'
      redirect_to action: :edit
    else
      flash[:notice] = '失敗しました。'
      render action: :edit
    end
  end

  # DELETE /households/1
  # DELETE /households/1.json
  def destroy
    @household.destroy
    respond_to do |format|
      format.html { redirect_to households_url, notice: 'Household was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_household
      @household = Household.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def household_params
      params.require(:household).permit(:use_date, :category_id, :cost, :memo, :use, :user_id)
    end
end
