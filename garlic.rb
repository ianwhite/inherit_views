garlic do
  repo 'inherit_views', :path => '.'

  repo 'rails', :url => 'git://github.com/rails/rails' #,  :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec' #, :local => "~/dev/vendor/spec"
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails' #, :local => "~/dev/vendor/spec"
  
  # these are for testing rails-2.0-2.1 branch
  repo 'ianwhite-rspec', :url => 'git://github.com/ianwhite/rspec' #, :local => "~/dev/ianwhite/spec"
  repo 'ianwhite-rspec-rails', :url => 'git://github.com/ianwhite/rspec-rails' #, :local => "~/dev/ianwhite/spec"
  

  # for target, default repo is 'rails', default branch is 'master'
  target '2.2-stable', :branch => 'origin/2-2-stable' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/master', :clone => true
      plugin 'ianwhite-rspec', :as => 'rspec'
      plugin 'ianwhite-rspec-rails', :as => 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec:rcov:verify"
      end
    end
  end
  
  target '2.0-stable', :branch => 'origin/2-0-stable' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/rails-2.0-2.1', :clone => true
      plugin 'ianwhite-rspec', :as => 'rspec'
      plugin 'ianwhite-rspec-rails', :as => 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec"
      end
    end
  end
  
  target '2.1-stable', :branch => 'origin/2-1-stable' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/rails-2.0-2.1', :clone => true
      plugin 'ianwhite-rspec', :as => 'rspec'
      plugin 'ianwhite-rspec-rails', :as => 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec"
      end
    end
  end
end
