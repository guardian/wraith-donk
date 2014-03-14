class ApplicationController < Sinatra::Base

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../', __FILE__)

  not_found do
    erb :not_found
  end
end
