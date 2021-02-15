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

class WikiRedirectsControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :enabled_modules, :wikis, :wiki_pages, :wiki_contents,
           :wiki_content_versions, :attachments,
           :issues, :issue_statuses, :trackers

  def setup
    User.current = nil
    @request.session[:user_id] = 1
  end

  def test_destroy
    wiki_page = WikiPage.find(2)
    old_title = wiki_page.title
    wiki_page.title = 'Test'
    wiki_page.save

    wiki_redirect = WikiRedirect.find_by(title: old_title, redirects_to: 'Test')

    delete :destroy, params: {id: wiki_redirect.id, project_id: wiki_page.wiki.project_id, wiki_page_id: 'Test'}

    assert_response :success
    assert_not WikiRedirect.exists?(id: wiki_redirect.id)
  end

  def test_destroy_without_permission
    @request.session[:user_id] = User.generate!.id

    wiki_page = WikiPage.find(2)
    old_title = wiki_page.title
    wiki_page.title = 'Test'
    wiki_page.save

    wiki_redirect = WikiRedirect.find_by(title: old_title, redirects_to: 'Test')

    delete :destroy, params: {id: wiki_redirect.id, project_id: wiki_page.wiki.project_id, wiki_page_id: 'Test'}

    assert_response :forbidden
    assert WikiRedirect.exists?(id: wiki_redirect.id)
  end

  def test_invalid_redirect_should_respond_with_404
    wiki_page = WikiPage.find(1)
    old_title = wiki_page.title
    wiki_page.title = 'New_Title'
    wiki_page.save

    other_wiki_page = WikiPage.find(2)
    other_wiki_page.title = 'Other_New_Title'
    other_wiki_page.save

    wiki_redirect = WikiRedirect.find_by(title: old_title, redirects_to: 'New_Title')

    delete :destroy, params: {id: wiki_redirect.id, project_id: other_wiki_page.wiki.project_id, wiki_page_id: 'Other_New_Title'}

    assert_response :not_found
    assert WikiRedirect.exists?(id: wiki_redirect.id)
  end
end
