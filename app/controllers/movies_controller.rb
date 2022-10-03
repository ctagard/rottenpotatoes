class MoviesController < ApplicationController
    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
       
      @all_ratings = Movie.all_ratings
      if session[:ratings_to_show].nil? && params[:ratings].nil? 
        @ratings_to_show = @all_ratings
      end
      if params[:ratings]
        @ratings_to_show = params[:ratings].keys 
        session[:ratings_to_show] = @ratings_to_show 
      end 
      if session[:sorting].nil? && session[:ratings_to_show] && params[:ratings].nil?
        @ratings_to_show = session[:ratings_to_show] 
        @sorting = session[:sorting]
        flash.keep 
        redirect_to movies_path({order_by: @sorting, ratings_to_show: @ratings_to_show})
      end 
      if params[:sorting] 
        session[:sorting] = params[:sorting]
      end 
      if session[:sorting] && params[:sorting].nil?
        @sorting = session[:sorting]
      end 

      @movies = Movie.all
      if session[:ratings_to_show] 
        @movies = Movie.with_ratings(session[:ratings_to_show])
        @ratings_to_show = session[:ratings_to_show]
      end 
      if session[:sorting] == "title" 
        @movies = Movie.title_sort
        @titlehighlight = "hilite p-3 mb-2 bg-warning" 
      elsif session[:sorting] == "date" 
        @movies = Movie.date_sort
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