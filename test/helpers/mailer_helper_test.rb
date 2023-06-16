# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2022  Jean-Philippe Lang
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

class MailerHelperTest < Redmine::HelperTest
  include MailerHelper

  fixtures :users

  # TODO: fix method name
  def test_1
    recipients = [User.find(2), User.find(3)]
    ret = show_recipients recipients
    assert_equal  'John Smith, Dave Lopper', ret
  end

  def test_2
    with_settings :show_recipients_limit => 3 do
      recipients = User.all.to_a
      ret = show_recipients recipients
      assert_equal  'Redmine Admin, John Smith, Dave Lopper...', ret
    end
  end
  
end