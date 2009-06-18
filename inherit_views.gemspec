Gem::Specification.new do |s|
	s.name = %q{inherit_views}
	s.version = '1.0.1'

	s.date = %q{2009-6-18}
	s.summary = %q{Allow rails views to inherit from each other.}
	s.description = %q{Allow rails views to inherit from each other.}
	s.authors = ["Ian W. White", "thedarkone"]
	s.email = "ian.w.white@gmail.com"
	s.homepage = "http://github.com/topherfangio/inherit_views/tree/master"

	s.has_rdoc = false
	s.require_paths = ["lib"]

	s.files = ["garlic.rb", "History.txt", "inherit_views.gemspec", "init.rb", "License.txt", "Rakefile", "README.rdoc", "Todo.txt"] + Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + Dir['spec/**/*.erb']

end
