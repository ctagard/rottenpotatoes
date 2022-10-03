class MoviesController < ApplicationController
    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
       
      @all_ratings = Movie.all_ratings
      # If there are no filters, nor were there any, display all ratings
      if session[:ratings_to_show].nil? && params[:ratings].nil? 
        @ratings_to_show = @all_ratings
      end
      # If we pass in a filter for rating, get the keys and store them in session 
      if params[:ratings]
        @ratings_to_show = params[:ratings].keys 
        session[:ratings_to_show] = @ratings_to_show 
      end 

      # If sorting is not nil, set session[:sorting] to be the sorting method. 
      if not params[:sorting].nil?
        session[:sorting] = params[:sorting]
      end 

      # If there is no sorting, and no rating filters, show the ratings stored in session
      #    with sorting stored in session. 
      if session[:sorting].nil? && session[:ratings_to_show] && params[:ratings].nil?
        @ratings_to_show = session[:ratings_to_show] 
        @sorting = session[:sorting]
        flash.keep 
        # Redirect to index with sorting as stored sort method, ratings as stored ratings. 
        redirect_to movies_path({sorting: @sorting, ratings_to_show: @ratings_to_show})
      end

      #If params are passed for sorting, store them in session. 
      if params[:sorting] 
        session[:sorting] = params[:sorting]
      end 

      #If no params for sorting, check session. 
      if session[:sorting] && params[:sorting].nil?
        @sorting = session[:sorting]
      end 

      @movies = Movie.all

      #Filter movies based on ratings_to_show
      if session[:ratings_to_show] 
        @movies = Movie.with_ratings(session[:ratings_to_show])
        @ratings_to_show = session[:ratings_to_show]
      end 

      #Determine sorting method. 
      if session[:sorting] == "title" 
        @movies = Movie.title_sort(@movies)
        @titlehighlight = "hilite p-3 mb-2 bg-warning" 
      elsif session[:sorting] == "date" 
        @movies = Movie.date_sort(@movies)
        @datehighlight = "hilite p-3 mb-2 bg-warning" 
      end 
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end