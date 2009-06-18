Gem::Specification.new do |s|
	s.name = %q{inherit_views}
	s.version = '1.0.2'

	s.date = %q{2009-06-18}
	s.summary = %q{Allow rails views to inherit from each other.}
	s.description = %q{Allow rails views to inherit from each other.}
	s.authors = ["Ian W. White", "thedarkone"]
	s.email = "ian.w.white@gmail.com"
	s.homepage = "http://github.com/topherfangio/inherit_views/tree/master"

	s.has_rdoc = true
	s.require_paths = ["inherit_views"]

	s.files = ["garlic.rb", "History.txt", "inherit_views.gemspec", "init.rb", "License.txt", "Rakefile", "README.rdoc", "Todo.txt", "inherit_views/inherit_views.rb", "rails/init.rb", "spec/controllers/a_controller_spec.rb", "spec/controllers/c_controller_spec.rb", "spec/controllers/b_controller_spec.rb", "spec/controllers/normal_controller_spec.rb", "spec/controllers/d_controller_spec.rb", "spec/spec_helper.rb", "spec/app.rb", "spec/mailers/mailer_spec.rb", "spec/views_for_specs/b/partial_in_b.html.erb", "spec/views_for_specs/b/bad_render_parent.html.erb", "spec/views_for_specs/b/partial_in_bc.html.erb", "spec/views_for_specs/b/in_abc.html.erb", "spec/views_for_specs/b/partial_render_parent.html.erb", "spec/views_for_specs/b/_partial_in_b.html.erb", "spec/views_for_specs/b/_partial_in_bc.html.erb", "spec/views_for_specs/b/collection_in_bc.html.erb", "spec/views_for_specs/b/in_b.html.erb", "spec/views_for_specs/b/in_ab.html.erb", "spec/views_for_specs/b/_partial_render_parent.html.erb", "spec/views_for_specs/b/render_parent.html.erb", "spec/views_for_specs/normal_mailer/email.erb", "spec/views_for_specs/normal_mailer/_partial.erb", "spec/views_for_specs/a/render_non_existent_partial.html.erb", "spec/views_for_specs/a/in_a.html.erb", "spec/views_for_specs/a/in_abc.html.erb", "spec/views_for_specs/a/in_ab.html.erb", "spec/views_for_specs/a/_partial_render_parent.html.erb", "spec/views_for_specs/a/render_parent.html.erb", "spec/views_for_specs/normal/partial_from_c.html.erb", "spec/views_for_specs/c/in_abc.html.erb", "spec/views_for_specs/c/_partial_in_bc.html.erb", "spec/views_for_specs/c/_partial_render_parent.html.erb", "spec/views_for_specs/c/in_c.html.erb", "spec/views_for_specs/c/render_parent.html.erb", "spec/views_for_specs/inheriting_mailer/email.erb"]

end
