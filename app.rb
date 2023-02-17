require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/user_repository'
require_relative 'lib/space_repository'
require_relative 'lib/booking_repository'
require_relative 'lib/database_connection'
require_relative 'lib/user'

class Application < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    current_user_id = session[:user_id]

    if current_user_id
      user_repo = UserRepository.new
      @user = user_repo.find('id', current_user_id)
    end

    repo = SpaceRepository.new
    @spaces = repo.find_all('available', true)

    erb(:index)
  end

  get '/signup' do
    erb(:signup)
  end

  post '/signup' do
    repo = UserRepository.new
    new_user = User.new
    new_user.name = params[:name]
    new_user.username = params[:username]
    new_user.email = params[:email]
    new_user.password = params[:password]

    repo.create(new_user)

    return erb(:login)
  end

  get '/login' do
    redirect('/') if session[:user_id]

    erb(:login)
  end

  get '/my_spaces/new' do
    redirect('/login') unless session[:user_id]

    erb(:new_space)
  end

  post '/my_spaces/new' do
    return status 400 unless %i[name price description].all? { |param| params.key?(param) }

    repo = SpaceRepository.new

    space = Space.new
    space.name = params[:name]
    space.available = true
    space.description = params[:description]
    space.price = params[:price]
    space.user_id = session[:user_id]

    repo.create(space)

    redirect '/my_spaces'
  end

  get '/my_spaces/:id/edit' do
    redirect('/login') unless session[:user_id]
  
    repo = SpaceRepository.new
  
    @space = repo.find('id', params[:id])
  
    erb(:edit_space, locals: {
      name: @space.name,
      description: @space.description,
      price: @space.price,
      available: @space.available
    })
  end

  post '/my_spaces/:id/edit' do
    redirect('/login') unless session[:user_id]
    
    repo = SpaceRepository.new
    space = repo.find('id', params[:id])
  
    space.name = params[:name]
    space.description = params[:description]
    space.price = params[:price]
    space.available = params[:available]
    
    repo.update(space, :name, space.name)
    repo.update(space, :description, space.description)
    repo.update(space, :price, space.price)
    repo.update(space, :available, space.available)
    
    redirect('/my_spaces')
  end

  get '/my_spaces' do
    redirect('/login') unless session[:user_id]

    repo = SpaceRepository.new

    @spaces = repo.find_all('user_id', session[:user_id])

    erb(:my_spaces)
  end

  post '/login' do
    return status 400 unless %i[username password].all? { |param| params.key?(param) }

    repo = UserRepository.new
    user = repo.find('username', params[:username])

    if user
      if params[:password] == user.password
        session.clear
        session[:user_id] = user.id
        redirect '/'
      else
        @error = 'Password incorrect'
        erb(:login)
      end
    else
      @error = 'Username does not exist'
      erb(:login)
    end
  end

  get '/bookings' do
    redirect('/login') unless session[:user_id]

    current_user_id = session[:user_id]

    repo = BookingRepository.new
    @bookings = repo.bookings_with_spaces(current_user_id)

    erb(:bookings)
  end

  get '/owner_bookings' do
    redirect('/login') unless session[:user_id]

    current_user_id = session[:user_id]

    repo = BookingRepository.new
    @owner_bookings = repo.bookings_with_spaces_owner(current_user_id)

    erb(:owner_bookings)
  end  

  post '/approve' do 
    redirect('/login') unless session[:user_id]
    current_user_id = session[:user_id]
    repo = BookingRepository.new
    booking = repo.find_all('id', params[:id])
    repo.update(booking.first, 'approved', 'true')

    repo = BookingRepository.new
    @owner_bookings = repo.bookings_with_spaces_owner(current_user_id)

    return erb(:owner_bookings)
  end
    
  post '/my_spaces/delete' do
    repo = SpaceRepository.new

    repo.delete(params[:id])

    redirect '/my_spaces'
  end

  post '/book_space' do
    redirect('/login') unless session[:user_id]

    return status 400 unless params.key?(:id)

    repo = BookingRepository.new

    booking = Booking.new
    booking.date_of_booking = params[:date_of_booking]
    booking.approved = false # tbc if approved / pending / declined
    booking.space_id = params[:id]
    booking.user_id = session[:user_id]

    repo.create(booking)

    redirect '/bookings'
  end

  post '/logout' do
    session.clear
    redirect '/'
  end
end
