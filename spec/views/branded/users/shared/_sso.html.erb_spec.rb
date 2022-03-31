# frozen_string_literal: true

require 'rails_helper'

describe 'users/shared/_sso' do
  include DmptoolHelper

  it 'renders correctly' do
    controller.prepend_view_path 'app/views/branded'

    user = create(:user, org: create(:org, name: 'Foo University', managed: true))
    # Partial is expecting a Form, so just stub one
    form_struct = OpenStruct.new
    form_struct.stubs(:hidden_field).returns('Foo')
    render partial: '/users/shared/sso', locals: { resource: user, form: form_struct }
    expect(rendered.include?('Your address is associated with:')).to eql(true)
    expect(rendered.include?("<h3>#{CGI.escapeHTML(user.org.name)}")).to eql(true)
    expect(rendered.include?('Foo')).to eql(true)
    expect(rendered.include?('Sign in with Institution to Continue')).to eql(true)
  end
end