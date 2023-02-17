require 'spec_helper'
require 'rack/test'
require_relative '../../app'

RSpec.describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.

  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect(response.status).to eq(200)
      expect(response.body).to include('Paradise Beach')
      expect(response.body).to include('£')
    end

    context 'not logged in' do
      it 'should show the login button when not logged in' do
        response = get('/', {}, { 'rack.session' => {} })

        expect(response.status).to eq(200)
        expect(response.body).to include('Log in')
      end
    end

    context 'logged in' do
      it 'should show the name of currently logged in user' do
        response = get('/', {}, { 'rack.session' => { user_id: '1' } })

        expect(response.status).to eq(200)
        expect(response.body).to include('Hello Joel')
        expect(response.body).to include('<a href="/my_spaces">My spaces</a>')
      end
    end
  end

  context 'GET /signup' do
    it 'provides a sign up page' do
      response = get('/signup')

      expect(response.status).to eq(200)
      expect(response.body).to include('Sign up')
    end
  end

  context 'POST /signup' do
    it 'returns the information for sign up' do
      response = post(
        '/signup',
        name: 'jack',
        username: 'jackio',
        password: 'password10',
        email: 'jack@makers.com'
      )

      expect(response.status).to eq(200)
      expect(response.body).to include('')
    end
  end

  context 'GET /login' do
    context 'not logged in' do
      it 'returns the login view' do
        response = get('/login', {}, { 'rack.session' => {} })

        expect(response.status).to eq(200)
        expect(response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end

    context 'logged in' do
      it 'redirects home' do
        response = get('/login', {}, { 'rack.session' => { user_id: '1' } })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('Hello Joel')
      end
    end
  end

  context 'GET /my_spaces' do
    context 'logged in' do
      it 'returns the my_spaces view' do
        response = get('/my_spaces', {}, { 'rack.session' => { user_id: '1' } })

        expect(response.status).to eq(200)
        expect(response.body).to include('Paradise Beach')
      end
    end

    context 'not logged in' do
      it 'returns the login view' do
        response = get('/my_spaces', {}, { 'rack.session' => {} })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(last_response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end
  end

  context 'POST /my_spaces/new' do
    it 'redirects to my_spaces view and displays new space' do
      response = post(
        '/my_spaces/new',
        {
          name: 'New space',
          price: 100,
          description: 'Lovely new space'
        },
        { 'rack.session' => { user_id: '1' } }
      )

      expect(response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('New space')
      expect(last_response.body).to include('£100 ppn')
      expect(last_response.body).to include('Lovely new space')
    end
  end

  context 'GET /bookings' do
    context 'logged in' do
      it 'returns the bookings view' do
        response = get('/bookings', {}, { 'rack.session' => { user_id: '1' } })

        expect(response.status).to eq(200)
        expect(response.body).to include('2023-02-13')
      end
    end

    context 'not logged in' do
      it 'returns the login view' do
        response = get('/bookings', {}, { 'rack.session' => {} })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(last_response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end
  end

  context 'POST /my_spaces/delete' do
    it 'removes space from my_spaces view' do
      response = post('/my_spaces/delete', {id: '2'}, { 'rack.session' => { user_id: '2' } })

      expect(response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('Countryside Lodge')
      expect(last_response.body).not_to include('Cityscapes')
    end
  end

  context 'POST /book_space' do
    context 'logged in' do
      it 'redirects to my_trips view' do
        response = post('/book_space', {id: '3', date_of_booking: Date.new(2023,02,16)}, { 'rack.session' => { user_id: '1' } })

        expect(response).to be_redirect
        follow_redirect!
        #expect(last_response.body).to include('<p>Space id: 3</p>')
        expect(last_response.body).to include('<p>Date: 2023-02-16</p>')
      end
    end

    context 'not logged in' do
      it 'redirects to login view' do
        response = get('/my_spaces/new', {}, { 'rack.session' => {} })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(last_response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end
  end

  context 'GET /my_spaces/new' do
    context 'logged in' do
      it 'returns my_space view' do
        response = get('/my_spaces/new', {}, { 'rack.session' => { user_id: '1' } })

        expect(response.status).to eq(200)
        expect(response.body).to include('<input name="name" placeholder="Name" type="text" required/>')
        expect(response.body).to include('<input name="price" placeholder="Price" type="number" required/>')
        expect(response.body).to include('<input name="description" placeholder="Description" type="text" required/>')
      end
    end

    context 'not logged in' do
      it 'redirects to login view' do
        response = get('/my_spaces/new', {}, { 'rack.session' => {} })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(last_response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end
  end

  context 'GET /my_spaces/:id/edit' do
    context 'logged in' do
      it 'returns a space with properties available for edit' do
        response = get('/my_spaces/:id/edit', {}, { 'rack.session' => { user_id: '1' } })

        expect(response.status).to eq(200)
        expect(response.body).to include('<form action="/my_spaces/')
        expect(response.body).to include('<label for="name">Name</label>')
      end
    end

    context 'not logged in' do
      it 'redirects to login view' do
        response = get('/my_spaces/new', {}, { 'rack.session' => {} })

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<input name="username" placeholder="Username" required/>')
        expect(last_response.body).to include('<input name="password" placeholder="Password" type="password" required/>')
      end
    end
  end

  context 'POST /my_spaces/:id/edit' do
    it 'redirects to my_spaces view and displays edited space' do
      response = post(
        '/my_spaces/1/edit',
        {
          name: 'Paradise Beach',
          price: 120,
          description: 'Seaside getaway - now with hot tub!'
        },
        { 'rack.session' => { user_id: '1' } }
      )

      expect(response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('Paradise Beach')
      expect(last_response.body).to include('£120 ppn')
      expect(last_response.body).to include('hot tub')
    end
  end

  context 'POST /login' do
    context 'given missing/incorrect parameters' do
      it 'returns 400' do
        response = post('/login', username: 'joelio', pass: 'password1')

        expect(response.status).to eq(400)
      end
    end

    context 'given valid username and password' do
      it 'redirects to homepage having logged in' do
        response = post(
          '/login',
          username: 'joelio',
          password: 'password1'
        )

        expect(response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('Hello Joel')
      end
    end

    context 'given invalid username and password' do
      it 'given an error message on login view' do
        response = post(
          '/login',
          username: 'joel',
          password: 'password'
        )

        expect(response.status).to eq(200)
        expect(response.body).to include('Username does not exist')
      end
    end

    context 'given invalid username' do
      it 'given an error message on login view' do
        response = post(
          '/login',
          username: 'joel',
          password: 'password1'
        )

        expect(response.status).to eq(200)
        expect(response.body).to include('Username does not exist')
      end
    end

    context 'given invalid password' do
      it 'given an error message on login view' do
        response = post(
          '/login',
          username: 'joelio',
          password: 'password'
        )

        expect(response.status).to eq(200)
        expect(response.body).to include('Password incorrect')
      end
    end
  end

  context 'POST /logout' do
    it 'logs out and redirects to the homepage' do
      response = post('/logout')

      expect(response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include('<button type="submit">Log in</button>')
    end
  end

  context 'GET /owner_bookings' do
    it 'directs to owner bookings page' do 
      response = get('/owner_bookings', {}, { 'rack.session' => { user_id: '1' } })

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Bookings on my listings</h1>')
    end
  end

  context 'POST /owner_bookings/approve' do 
    it "approves booking request, button dissapears, shows approved under property" do 
      response = post('/owner_bookings/approve', {}, { 'rack.session' => { user_id: '1' } })

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Bookings on my listings</h1>')
      expect(response.body).to include('<p>Approved: true</p>')
      expect(response.body).to include('Paradise Beach')
    end
  end
end
