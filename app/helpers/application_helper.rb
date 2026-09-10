module ApplicationHelper
  def nav_class(path)
    active = case path
    when root_path then controller_name == "weeks"
    when recipes_path then controller_name == "recipes"
    when shopping_lists_path then controller_name == "shopping_lists"
    when settings_path then %w[settings users households].include?(controller_name)
    else current_page?(path)
    end
    active ? "active" : ""
  end
end