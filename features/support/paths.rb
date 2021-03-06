module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the (main|home) page$/ then '/'
    when /^the listing page$/ then '/apartments'
    when /^the details page for "(.+)"$/ then "/apartments/#{Apartment.find_by(name: $1).id}"
    when /^the editing page for "(.+)"$/ then "/apartments/#{Apartment.find_by(name: $1).id}/edit"
    when /^the add apartment page$/ then '/apartments/new'
    when /^the register page$/ then '/register'
    when /^the login page$/ then '/login'
    when /^the new comment page for "(.+)"$/ then "/comments/new?apartment_id=#{Apartment.find_by(name: $1).id}"
    when /^the edit comment page for apartment "(.+)" and comment (\d+)$/ then "/comments/#{$2}/edit?apartment_id=#{Apartment.find_by(name: $1).id}"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
