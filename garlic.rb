garlic do
  repo 'inherit_views', :path => '.'

  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'

  # Make sure you set up tracking branches for origin/rails-2.2, and origin/rails-2.0-2.1
  [ 
    {:rails => 'master',      :inherit_views => 'master'},
    {:rails => '2-3-stable',  :inherit_views => 'master'},
    {:rails => '2-2-stable',  :inherit_views => 'rails-2.2'},
    {:rails => '2-1-stable',  :inherit_views => 'rails-2.0-2.1'},
    {:rails => '2-0-stable',  :inherit_views => 'rails-2.0-2.1'}
  ].each do |target|

    target target[:rails], :branch => "origin/#{target[:rails]}" do
      prepare do
        plugin 'inherit_views', :branch => "origin/#{target[:inherit_views]}", :clone => true
        plugin 'rspec', :branch => 'origin/1.1-maintenance'
        plugin 'rspec-rails', :branch => 'origin/1.1-maintenance' do
          sh "script/generate rspec -f"
        end
      end
      run do
        cd "vendor/plugins/inherit_views" do
          sh "rake rcov:verify"
        end
      end
    end
    
  end
end