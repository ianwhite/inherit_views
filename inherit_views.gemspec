# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{inherit_views}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ian White"]
  s.date = %q{2009-06-19}
  s.description = %q{Allow rails controllers to inherit views.}
  s.email = %q{ian.w.white@gmail.com}
  s.files = ["lib/inherit_views/version.rb", "lib/inherit_views.rb", "License.txt", "README.rdoc", "Todo.txt", "History.txt", "spec/controllers/a_controller_spec.rb", "spec/controllers/b_controller_spec.rb", "spec/controllers/c_controller_spec.rb", "spec/controllers/d_controller_spec.rb", "spec/controllers/normal_controller_spec.rb", "spec/mailers/mailer_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ianwhite/inherit_views/tree}
  s.rdoc_options = ["--title", "Pickle", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Allow rails controllers to inherit views.}
  s.test_files = ["spec/controllers/a_controller_spec.rb", "spec/controllers/b_controller_spec.rb", "spec/controllers/c_controller_spec.rb", "spec/controllers/d_controller_spec.rb", "spec/controllers/normal_controller_spec.rb", "spec/mailers/mailer_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
