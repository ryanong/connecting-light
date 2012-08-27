class AdminSettingsController < ApplicationController
  # GET /admin_settings
  # GET /admin_settings.json
  def index
    @admin_settings = AdminSetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: AdminSetting.fetch.merge(time: Time.now.to_i) }
    end
  end

  # GET /admin_settings/1
  # GET /admin_settings/1.json
  def show
    @admin_setting = AdminSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_setting }
    end
  end

  # GET /admin_settings/new
  # GET /admin_settings/new.json
  def new
    @admin_setting = AdminSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_setting }
    end
  end

  # GET /admin_settings/1/edit
  def edit
    @admin_setting = AdminSetting.find(params[:id])
  end

  # POST /admin_settings
  # POST /admin_settings.json
  def create
    @admin_setting = AdminSetting.new(params[:admin_setting])

    respond_to do |format|
      if @admin_setting.save
        format.html { redirect_to @admin_setting, notice: 'Admin setting was successfully created.' }
        format.json { render json: @admin_setting, status: :created, location: @admin_setting }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.json
  def update
    @admin_setting = AdminSetting.find(params[:id])

    respond_to do |format|
      if @admin_setting.update_attributes(params[:admin_setting])
        format.html { redirect_to @admin_setting, notice: 'Admin setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_settings/1
  # DELETE /admin_settings/1.json
  def destroy
    @admin_setting = AdminSetting.find(params[:id])
    @admin_setting.destroy

    respond_to do |format|
      format.html { redirect_to admin_settings_url }
      format.json { head :no_content }
    end
  end
end
