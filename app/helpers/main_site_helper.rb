# Methods that might be useful in templates on the main site
module MainSiteHelper
  def current_user_can?( capability )
    return false if current_user.blank?

    current_user.can? capability
  end

  def shared_content( name )
    SharedContentElement.where( name: name ).pick( :content )
  end
end