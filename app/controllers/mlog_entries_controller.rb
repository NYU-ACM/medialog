require 'open-uri'

class MlogEntriesController < ApplicationController
  include ApplicationHelper
  include MlogEntriesHelper
  
  before_action :set_mlog_entry, only: [:show, :edit, :update, :destroy]

  def media
    @result = JSON.parse(open("http://localhost:9000/accession/media/" + params[:id]).read)
    puts @result.class
  end
  
  def textfile
    @request = params[:file].split("_")
    @partner = MLOG_VOCAB["filename_partner_codes"][@request[0]]
    @col_code = @request[1] + @request[2]
    @media_num = @request[3]
    @result = MlogEntry.where("collection_code = ? and partner_code = ? and media_id =?", @col_code, @partner, @media_num)
    @size = @result.size
    puts @size.class

    respond_to do |format|
      format.html { 
        if @size == 1 then render json: @result[0].id 
        elsif @size == 0 then render json: "no resource" 
        end
      }

      format.json { 
        if @size == 1 then render json: @result[0].id 
        elsif @size == 0 then render json: "no resource" 
        end
      }
    end
  end

  def repository

    collections = Collection.where("partner_code = ?", params[:repo])
    @colls = get_sizes(collections)

    @sum_stock = 0.0
    @sum_image = 0.0

    @colls.each do |coll|
      if coll[1].stock_size != nil then
        @sum_stock = @sum_stock + coll[1].stock_size
      end

      if coll[1].image_size != nil then
        @sum_image = @sum_image + coll[1].image_size
      end
    end
    
    @sum_image = human_size(@sum_image)
    @sum_stock = human_size(@sum_stock)
    @min_cols = getMinimalCols
 
  end
  
  def nav 
    mlog = MlogEntry.find(params[:id]) 
    id = mlog.media_id
    nId = 0
    if params[:dir] == "next"
     nId = id + 1
    elsif params[:dir] == "previous"
      nId = id - 1
    end

    nextMlog = MlogEntry.where("collection_id = ? and media_id =?", mlog.collection_id, nId)
    
    if nextMlog[0] != nil 
      redirect_to :action => 'show',  :id => nextMlog[0]
    else
      flash[:notice] = "The #{params[:dir]} record does not exist."
      redirect_to :action => 'show',  :id => mlog
    end 

  end

  def clone
    source_entry = MlogEntry.find(params[:id])
    @mlog_entry = MlogEntry.new
    @mlog_entry[:collection_id] = source_entry[:collection_id]
    @mlog_entry[:accession_num] = source_entry[:accession_num]
    @mlog_entry[:mediatype] = source_entry[:mediatype]
    @mlog_entry[:box_number] = source_entry[:box_number]
    @mlog_entry[:media_id] = source_entry[:media_id] + 1
    @col = Collection.find(source_entry.collection_id)
  end

  def accession
    
    @mlog_entries = MlogEntry.where("accession_num = ? and collection_id = ?", params[:accession], params[:collection])
    @col = Collection.find(params[:collection])
    @sum = 0.0
    @image_sum = 0.0
    @mlog_entries.each do |entry|
      if(entry.stock_unit == 'MB') then
        @sum = @sum + mb_to_byte(entry.stock_size_num)
      elsif (entry.stock_unit == 'GB') then
        @sum = @sum + gb_to_byte(entry.stock_size_num)
      end

      if(entry.image_size_bytes != nil) then
        @image_sum = @image_sum + entry.image_size_bytes
      end
    end

    @sum = human_size(@sum)
    @image_sum = human_size(@image_sum)
    @mlog_entries = MlogEntry.where("accession_num = ? and collection_id = ?", params[:accession], params[:collection]).order(media_id: :asc).page params[:page]

  end

  def mlog_json
    respond_to do |format|
      format.html { 
        render json: MlogEntry.where("id = ?", params[:id])
      }

      format.json { 
        render json: params[:id]
      }
    end
  end

  # GET /mlog_entries
  # GET /mlog_entries.json
  def index
    @mlog_entries = MlogEntry.order(updated_at: :desc).page params[:page]
    @cols = getMinimalCols
  end

  # GET /mlog_entries/1
  # GET /mlog_entries/1.json
  def show
    @creator = "unknown"
    @modifier = "unknown"
    @collection = Collection.find(@mlog_entry.collection_id)
    if @mlog_entry.created_by != nil then @creator = User.find(@mlog_entry.created_by).email end
    if @mlog_entry.modified_by != nil then @modifier = User.find(@mlog_entry.modified_by).email end
  end

  # GET /mlog_entries/new
  def new
    puts params
    @mlog_entry = MlogEntry.new
    @col = Collection.find(params[:id])
  end

  # GET /mlog_entries/1/edit
  def edit
    u = current_user
    @user = User.find(u)
    @col = Collection.find(@mlog_entry.collection_id) 
  end

  # POST /mlog_entries
  # POST /mlog_entries.json
  def create
    @mlog_entry = MlogEntry.new(mlog_entry_params)
    @col = Collection.find(@mlog_entry.collection_id)
    respond_to do |format|
      if @mlog_entry.save
        format.html { redirect_to @col, notice: 'Entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @mlog_entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @mlog_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mlog_entries/1
  # PATCH/PUT /mlog_entries/1.json
  def update
    @col = Collection.find(@mlog_entry.collection_id)
    respond_to do |format|
      if @mlog_entry.update(mlog_entry_params)
        format.html { redirect_to @col, notice: 'Entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mlog_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mlog_entries/1
  # DELETE /mlog_entries/1.json
  def destroy
    @mlog_entry.destroy
    respond_to do |format|
      format.html { redirect_to mlog_entries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mlog_entry
      @mlog_entry = MlogEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mlog_entry_params
      params.require(:mlog_entry).permit(:accession_num, :media_id, :mediatype, 
        :manufacturer, :manufacturer_serial, :label_text, :media_note, :photo_url, :image_filename, :interface, 
        :imaging_software, :hdd_interface, :imaging_success, :interpretation_success, :imaged_by, :imaging_note, 
        :image_format, :encoding_scheme, :partition_table_format, :number_of_partitions, :filesystem, :has_dfxml, 
        :has_ftk_csv, :has_mactime_csv, :image_size_bytes, :md5_checksum, :sha1_checksum, :date_imaged, :date_ftk_loaded, 
        :date_metadata_extracted, :date_photographed, :date_qc, :date_packaged, :date_transferred, :number_of_image_segments, 
        :ref_id, :box_number, :stock_size, :sip_id, :original_id, :disposition_note, :stock_unit, :stock_size_num, :created_by, :modified_by, :collection_id, :accession_id)
    end
end
