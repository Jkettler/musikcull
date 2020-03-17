class ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :update, :destroy]

  # GET /artists
  def index
    @artists = Artist.all

    render json: to_api(@artists)
  end

  # GET /artists/1
  def show
    render json: to_api(@artist)
  end

  # POST /artists
  def create
    @artist = Artist.new(artist_params)

    if @artist.save
      render json: to_api(@artist), status: :created, location: @artist
    else
      render json: to_api(@artist).errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /artists/1
  def update
    if @artist.update(artist_params)
      render json: to_api(@artist)
    else
      render json: to_api(@artist).errors, status: :unprocessable_entity
    end
  end

  def page
    @artists = Artist.page(params[:page])
    render json: to_api(@artists)
  end

  # DELETE /artists/1
  def destroy
    @artist.destroy
  end

  def search
    @results = Artist.search(params[:search_term])
    render json: to_api(@results)
  end

  private
    def set_artist
      @artist = Artist.find(params[:id])
    end

    def to_api(collection)
      ArtistSerializer.new(collection).serialized_json
    end

    # Only allow a list of trusted parameters through.
    def artist_params
      params.require(:artist).permit(:name)
    end
end
