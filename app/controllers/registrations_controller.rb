class RegistrationsController < Devise::RegistrationsController
  def new
    build_resource({})
    resource.build_account
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    resource.account.name = "#{resource.first_name} #{resource.last_name}" if resource.account.name.blank?

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, account_attributes: [:name])
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

  def build_resource(hash = {})
    super
    return unless hash[:account_attributes]

    resource.account = Account.new(hash[:account_attributes])
  end
end
