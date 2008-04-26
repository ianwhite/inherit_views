# This is for running inherit_views specs against its target versions of rails
#
# To do so, do the following:
#   - Edit the config below if you wish, to let garlic know about your local
#      clones of rails, rspec and rspec-rails
#   - Download garlic (it's tiny)
#       (standing in inheirt_views)
#       git clone git://github.com/ianwhite/garlic.git garlic
#   - Run garlic
#       rake garlic:all
#
# Subsequent runs can be done with 
#       rake garlic:run
#
# All of the work and dependencies will be created in the galric dir, and the
# garlic dir can safely be deleted at any point

garlic do
  # default paths are 'garlic/work', and 'garlic/repos'
  # work_path 'garlic/work'
  # repo_path 'garlic/repos'

  # repo, give a url, specify :local to use a local repo (faster
  # and will still update from the origin url)
  repo 'rails', :url => 'git://github.com/rails/rails' #, :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/ianwhite/rspec-rails'
  repo 'inherit_views', :url => '.'

  # for target, default repo is 'rails', default branch is 'master'
  target 'edge'
  target '2.0-stable', :branch => 'origin/2-0-stable'
  target '2.0.2', :tag => 'v2.0.2'

  all_targets do
    prepare do
      plugin 'rspec'
      plugin 'rspec-rails', :branch => 'origin/aliased-render-partial' do
        sh "script/generate rspec -f"
      end
      plugin 'inherit_views'
    end
  
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec:rcov:verify"
      end
    end
  end
end
