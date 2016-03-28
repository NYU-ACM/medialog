class CollectionsController < ApplicationController
  
  def index
    @collections = Collection.order(updated_at: :desc)
  end

  def show
    @collection = Collection.find(params[:id])
    @accessions = Accession.where("collection_id = ?", @collection.id)
    @min_accessions = getMinAccessions
    @mlog_entries = MlogEntry.where("collection_id = ?", @collection.id).order(media_id: :asc).page params[:page]
    @summaries = get_summaries(@mlog_entries)
  end

  def edit
    @col = Collection.find(params[:id])
  end

  def destroy

    col = Collection.find(params[:id])
    mlog_entries = MlogEntry.where("collection_id = ?", col.id)
  
    mlog_entries.each do |entry|
      entry.destroy
    end
  
    col.destroy
    redirect_to :controller => "mlog_entries", :action => "repository", :repo => col.partner_code
  end

  def update
    @col = Collection.find(params[:id])
    @col.update(collection_params)
    redirect_to @col
  end

  def new 
  end

  def create 
    @collection = Collection.new(collection_params)
    @collection.save
    redirect_to @collection
  end

  def uuids
    @collection = Collection.find(params[:id])
    @mlog_entries = MlogEntry.where("collection_id = ?", params[:id]).order(media_id: :asc)
  end

  private 
    def collection_params
      params.require(:collection).permit(:title, :collection_code, :partner_code)
    end
end
