require File.join(File.dirname(__FILE__), 'garlic/lib/garlic_tasks')

garlic do
  # default paths are 'garlic/work', and 'garlic/repos'
  work_path "tmp/work"
  repo_path "tmp/repos"
  
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