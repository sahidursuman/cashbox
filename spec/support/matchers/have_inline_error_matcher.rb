RSpec::Matchers.define :have_inline_error do |expected|
  define_method :for_field do |field|
    @field = field
    self
  end

  define_method :for_field_name do |field_name|
    @field_name = field_name
    self
  end

  def options
    if @field
      [".form-group", text: @field]
    elsif @field_name
      [:xpath, "//*[contains(@class,'form-group') and (descendant::input[@name='#{@field_name}'] or descendant::textarea[@name='#{@field_name}'])]"]
    end
  end

  match_for_should do |page|
    within(*options) do
      page.has_content?(expected)
    end
  end

  match_for_should_not do |page|
    within(*options) do
      page.has_no_content?(expected)
    end
  end

  failure_message_for_should do |page|
    %Q{expected to have inline error \"#{expected}\" for field \"#{@field}\"}
  end

  failure_message_for_should_not do |page|
    %Q{expected to not have inline error \"#{expected}\" for field \"#{@field}\"}
  end

  description do
    %Q{have inline error \"#{expected}\" for field \"#{@field}\"}
  end
end