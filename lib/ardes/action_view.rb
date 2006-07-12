class ActionView::Base
private
  def full_template_path(template_path, extension)
    # If the template exists in the normal application directory, return that path
    full_path = "#{@base_path}/#{template_path}.#{extension}"
    return full_path if File.exist?(full_path)

    # Otherwise, check in any additional template paths in order
    controller.inherit_views_from.each do |from|
      inherited_template_path = template_path.sub /^.*\//, from.to_s + '/'
      inherited_full_path = "#{@base_path}/#{inherited_template_path}.#{extension}"
      return inherited_full_path if File.exist?(inherited_full_path)
    end

    # If it cannot be found in additional paths, return the default path
    return full_path
  end
end