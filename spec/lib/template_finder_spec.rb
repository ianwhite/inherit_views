require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

# this tests branching for BC purposes as TemplateFinder changed the ActionView api
# remove (and code iin inherit_views) when no longer supporting Rails 2.0.2

describe NoTemplateFinderController do  
  it ".file_exists_in_template? should call template.file_exists?" do
    template = mock('template')
    template.should_receive(:file_exists?).with('path')
    NoTemplateFinderController.file_exists_in_template?(template, 'path')
  end
end

describe WithTemplateFinderController do  
  it ".file_exists_in_template? should call template.finder.file_exists?" do
    template = mock('template')
    finder = mock('finder')
    template.stub!(:finder).and_return(finder)
    finder.should_receive(:file_exists?).with('path')
    WithTemplateFinderController.file_exists_in_template?(template, 'path')
  end
end