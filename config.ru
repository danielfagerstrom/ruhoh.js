require 'rack'
#require './lib/ruhoh'
#Ruhoh.setup
#Ruhoh::Posts.generate
#Ruhoh::Pages.generate
#Ruhoh::Watch.start

use Rack::Lint
use Rack::ShowExceptions
use Rack::Static, {
  :root => '.',
  :urls => ['/client', '/database', '/config.yml', '/pages', '/posts', '/themes', '/partials']
}

run Proc.new { |env|
  [ 
    200, 
    {
      'Content-Type' => 'text/html', 
      'x-ruhoh-site-source-folder' => '/'
    }, 
    [File.read('./index.html')]
  ]
}
