# This is for running specs against target versions of rails
#
# To use do
#   - cp garlic_example.rb garlic.rb
#   - rake get_garlic
#   - [optional] edit this file to point the repos at your local clones of
#     rails, rspec, and rspec-rails
#   - rake garlic:all
#
# All of the work and dependencies will be created in the galric dir, and the
# garlic dir can safely be deleted at any point

garlic do
  # default paths are 'garlic/work', and 'garlic/repos'
  # work_path 'garlic/work'
  # repo_path 'garlic/repos'

  # repo, give a url, specify :local to use a local repo (faster
  # and will still update from the origin url)
  repo 'rails', :url => 'git://github.com/rails/rails' #,  :local => "~/dev/vendor/rails"
  # using own clone of rspec, until aliased-render-partial gets fixed.
  repo 'rspec', :url => 'git://github.com/ianwhite/rspec'
  repo 'rspec-rails', :url => 'git://github.com/ianwhite/rspec-rails'
  repo 'inherit_views', :path => '.'

  # for target, default repo is 'rails', default branch is 'master'
  target 'edge'
  target '2.0-stable', :branch => 'origin/2-0-stable'
  target '2.0.3', :tag => 'v2.0.3'
  target '2.1.0-RC1', :tag => 'v2.1.0_RC1' 

  all_targets do
    prepare do
      plugin 'rspec', :branch => 'origin/aliased-render-partial'
      plugin 'rspec-rails', :branch => 'origin/aliased-render-partial' do
        sh "script/generate rspec -f"
      end
      plugin 'inherit_views', :clone => true # so we can work on it and push fixes upstream
    end
  
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec:rcov:verify"
      end
    end
  end
end
