class StorageController < ConsoleController
  include AsyncAware

  def new
    user_default_domain
    user_information
    application_information
  end

  def show
    user_default_domain
    user_information
    application_information

    redirect_to new_application_storage_path unless @user.can_modify_storage?

    gear_group_information
  end

  def update
    user_default_domain
    user_information
    application_information
    gear_group_information

    @cartridge = @application.find_cartridge(params[:id]) or raise RestApi::ResourceNotFound.new(Cartridge.model_name, params[:id])

    @cartridge.additional_gear_storage = Integer(params[:cartridge][:additional_gear_storage])

    if @cartridge.save
      redirect_to application_storage_path, :flash => {:success => "Updated storage for cartridge '#{@cartridge.display_name}'"}
    else
      #FIXME: Should this be handled automatically?
      errors =  @cartridge.errors.messages.values.flatten
      redirect_to application_storage_path, :flash => {:error => errors }
    end
  end

  private
  def user_information
    @user = User.find :one, :as => current_user
  end

  def application_information
    @application = @domain.find_application params[:application_id]
  end

  def gear_group_information
    @gear_groups = @application.cartridge_gear_groups
  end
end
