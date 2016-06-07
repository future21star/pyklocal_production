module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)

    case page_name

    when /the home page/
    	'/'
    when /the user profile page/
      '/profile/'
    when /the Work_report/
      '/tracker/work_reports/new'
    when /my project page/
      '/tracker/projects/#{project_id}/dashboard'
    when /the tracker/
      '/tracker/'
    when /the company profile page/
      '/corps/'
    when /index page/
      ''
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
