
namespace :site do
  
  desc "Create a new website framework"
  task :new do
    name = ENV['name']
    abort("Must specify a name for your website") unless name
    
    FileUtils.cp_r('./_scaffold/blog', "./#{name}")
    FileUtils.cp_r('./_scaffold/theme', "./#{name}/_themes/stock")
  end
  
end

namespace :theme do

  desc "Creat a new theme framework"
  task :new do
    name = ENV['name']
    abort("Must specify a name for your website") unless name
    
    new_theme_path = "#{RuhOh.config.site_source_path}/_themes/#{name}"
    FileUtils.cp_r('./_scaffold/theme', new_theme_path)
  end

end

task :generate => 'generate:all'

namespace :generate do

  # Public: Generate data from the site assets (posts/pages).
  # The data structures are referred to as "dictionaries".
  #
  # Returns: Nothing.
  task :all => ['pages', 'posts']

  task :pages do 
    RuhOh::Pages::generate
  end
  
  task :posts do
    RuhOh::Posts::generate
  end

end  