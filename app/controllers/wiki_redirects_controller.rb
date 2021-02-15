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

class WikiRedirectsController < ApplicationController
  before_action :find_wiki_redirect, :authorize

  def destroy
    if @wiki_redirect.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to project_wiki_page_path(@page.project, @page.title)
    end
  end

  private

  def find_wiki_redirect
    @project = Project.find(params[:project_id])
    @page = Wiki.find_page(params[:wiki_page_id], project: @project)
    @wiki_redirect=WikiRedirect.where(redirects_to: @page.title).find(params[:id])
    render_404 unless @wiki_redirect
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
