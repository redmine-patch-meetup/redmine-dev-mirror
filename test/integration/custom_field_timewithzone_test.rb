# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2020  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class CustomFieldsTimewithzoneTest < Redmine::IntegrationTest
  fixtures :projects,
           :users, :email_addresses,
           :user_preferences,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  def setup
    @field = IssueCustomField.find(12)
    @issue = Issue.find(14)
    log_user('jsmith', 'jsmith')
    @user = User.find(session[:user_id])
  end

  def test_get_issue_with_timewithzone_custom_field
    assert_nil ENV['TZ']
    assert_equal 'UTC', RedmineApp::Application.config.time_zone
    assert_equal :local, config.default_timezone
    assert_equal 'en', Setting.default_language

    # get issues/14 in tz=nil
    assert_nil @user.preference.time_zone
    get "/issues/#{@issue.id}"
    assert_response :success
    assert_select ".cf_#{@field.id} .value", :text => '03/11/2011 05:46 AM'
    assert_select 'input[name=?][value=?]', "issue[custom_field_values][#{@field.id}]", '2011-03-11T05:46'
    
    # get issues/14 in tz='UTC'
    @user.preference.time_zone = 'UTC'
    @user.preference.save
    get "/issues/#{@issue.id}"
    assert_response :success
    assert_select ".cf_#{@field.id} .value", :text => '03/11/2011 05:46 AM'
    assert_select 'input[name=?][value=?]', "issue[custom_field_values][#{@field.id}]", '2011-03-11T05:46'
    
    # get issues/14 in lang="ja", tz='Tokyo' (+0900)
    @user.preference.time_zone = 'Tokyo'
    @user.preference.save
    @user.language = "ja"
    @user.save
    get "/issues/#{@issue.id}"
    assert_response :success
    assert_select ".cf_#{@field.id} .value", :text => '2011/03/11 14:46'
    assert_select 'input[name=?][value=?]', "issue[custom_field_values][#{@field.id}]", '2011-03-11T14:46'
  end

  def test_put_issue_with_timewithzone_custom_field
    # update issues/14 in lang="ja", tz='Tokyo' (+0900)
    @user.preference.time_zone = 'Tokyo'
    @user.preference.save
    @user.language = "ja"
    @user.save
    put "/issues/#{@issue.id}",
    :params => {
      :issue => {
        :custom_field_values => {@field.id.to_s => "1985-08-12T18:56"}  # in tz=Asia/Tokyo +0900
      }
    }
    assert_equal "1985-08-12T09:56:00Z", CustomValue.find_by(:customized_id=>@issue.id, :custom_field_id => @field.id).value
    
    # update issues/14 in tz=nil
    @user.preference.time_zone = nil
    @user.preference.save
    put "/issues/#{@issue.id}",
    :params => {
      :issue => {
        :custom_field_values => {@field.id.to_s => "1912-04-14T23:40"}  # in UTC
      }
    }
    assert_equal "1912-04-14T23:40:00Z", CustomValue.find_by(:customized_id=>@issue.id, :custom_field_id => @field.id).value
  end

end
