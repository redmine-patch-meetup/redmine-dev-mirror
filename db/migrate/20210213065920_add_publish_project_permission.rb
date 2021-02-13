class AddPublishProjectPermission < ActiveRecord::Migration[5.2]
  def up
    Role.all.each do |role|
      role.add_permission! :publish_project if role.has_permission?(:add_project) || role.has_permission?(:edit_project)
    end
  end
end
