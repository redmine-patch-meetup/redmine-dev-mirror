# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2021  Jean-Philippe Lang
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
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :attachments

  def setup
    @field = IssueCustomField.find(12)
    @issue = Issue.find(3)
    @user = User.find_by(:login => 'jsmith')
    log_user(@user.login, @user.login)
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

  def test_bulk_edit
    get(
      "/issues/bulk_edit",
      :params => {
        :ids => [1, @issue.id],
      }
    )
    assert_response :success
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

    assert_response :found
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

  def test_put_issue_with_timewithzone_custom_field_mail
    
    ActionMailer::Base.deliveries.clear
    Setting.plain_text_mail = '0'
    
    @user.preference.time_zone = 'Tokyo'
    @user.preference.save
    @user.language = "ja"
    @user.save
    
    watcher = User.find_by(:login => 'dlopper')
    watcher.preference = UserPreference.new(:user_id => watcher.id)
    watcher.preference.time_zone = 'Newfoundland'
    watcher.preference.save
    watcher.language = "fr"
    watcher.save
    
    put "/issues/#{@issue.id}",
    :params => {
      :issue => {
        :custom_field_values => {@field.id.to_s => "2005-04-25T09:18"}  # in tz=Asia/Tokyo +0900
      }
    }

    ActionMailer::Base.deliveries.each do |mail|
      recipient = mail.header["BCC"].value.first
      case
      when recipient.starts_with?("jsmith@")
        assert_mail_body_match 'Epoch を 2011/03/11 14:46 から 2005/04/25 09:18 に変更', mail
      when recipient.starts_with?("dlopper@")
        assert_mail_body_match 'Epoch changé de 11/03/2011 02:16 à 24/04/2005 21:48', mail
      else
        flunk
      end
    end
  end

  test "timewithzone may always utc.iso8601 via api" do
    @user.preference.time_zone = 'Tokyo'
    @user.preference.save
    @user.language = "ja"
    @user.save
    with_settings :rest_api_enabled => '1' do
      get '/issues/3.xml', :headers => credentials(@user.login)
      assert_response :success
      assert_equal 'application/xml', response.media_type
      assert_select "custom_field[id=12] value", '2011-03-11T05:46:18Z', 'timewithzone may always utc.iso8601 via api'
    end
  end

end
