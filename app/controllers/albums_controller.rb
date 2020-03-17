class AlbumsController < ApplicationController
  before_action :set_album, only: [:show, :update, :destroy]

  def index
    @albums = Album.includes(:artists)
    render json: to_api(@albums)
  end

  def page
    @albums = Album.includes(:artists).page(params[:page])
    render json: to_api(@albums)
  end

  # GET /albums/1
  def show
    render json: to_api(@album)
  end

  def title_frequency
    render json: Album.title_frequency
  end

  # POST /albums
  def create
    @album = Album.create_with_nested_attributes(album_params)

    if @album.save
      render json: to_api(@album), status: :created, location: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /albums/1
  def update
    if @album.update_nested_attributes(album_params)
      render json: to_api(@album)
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # DELETE /albums/1
  def destroy
    @album.destroy
  end

  def search
    @results = Album.search_with_artists(params[:search_term])

    render json: to_api(@results)
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def to_api(collection)
    options = {}
    options[:include] = [:artists, :'artists.name']
    AlbumSerializer.new(collection, options).serialized_json
  end

  # Only allow a trusted parameter "white list" through.
  def album_params
    params.require(:album).permit(:title, :year, :condition, [{artists: :name}])
  end
end
