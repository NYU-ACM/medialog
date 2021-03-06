class AccessionsController < ApplicationController

  def index
  	@accessions = Hash.new
    Accession.order(id: :asc).each do |acc|
      @accession = Hash.new
      @accession[:id] = acc[:id]
      @accession[:num] = acc[:accession_num]
      col = Collection.where("id = ?", acc[:collection_id])
      if(col.empty?) then
        @accession[:col_id] = "NA"
        @accession[:col_code] = "NA"
        @accession[:col_title] = "NA"
        @accession[:partner_code] = "NA"
      else
        @accession[:col_id] = col[0][:id]
        @accession[:col_code] = col[0][:collection_code]
        @accession[:col_title] = col[0][:title]
        @accession[:partner_code] = col[0][:partner_code]
      end 
      mlog_entries = MlogEntry.where("accession_id = ?", acc.id)
      type_data = get_type_data(mlog_entries)
      @accession[:count] = mlog_entries.size
      @accession[:extent] = human_size(get_total_size(type_data))
      @accession[:state] = acc[:accession_state]
      @accessions[acc.id] = @accession

    end  
  end

  def lookup
    puts params
    mlog_entries = lookup_mlog_entry(params[:collection_id], params[:media_id])
    if mlog_entries.size != 0 then 
      redirect_to mlog_entries[0]
    else
      flash[:notice] = "id #{params[:media_id]} does not exist in current collection."
      redirect_to Accession.find(params[:accession_id])
    end
  end

  def show
    @creator = "unknown"
    @modifier = "unknown"
    
    @accession = Accession.find(params[:id])
    @collection = Collection.find(@accession[:collection_id])

    @collections = getMinCollections
    @min_accessions = getMinAccessions
    
    @mlog = MlogEntry.where(:accession_id => @accession[:id])
    @mlog_entries = MlogEntry.where(:accession_id => @accession.id).order(media_id: :asc).page params[:page]
    
    @type_data = get_type_data(@mlog)
    @total_size = get_total_size(@type_data)

    if @accession.created_by != nil then @creator = User.find(@accession.created_by).email end
    if @accession.modified_by != nil then @modifier = User.find(@accession.modified_by).email end

  end

  def new
  	@collection = Collection.find(params[:collection_id])
  end

  def create
    @accession = Accession.new(accession_params)
    @accession.save
    @collection = Collection.find(@accession[:collection_id])
    redirect_to @collection
  end

  def edit
    @accession = Accession.find(params[:id])
    @collection = Collection.find(@accession[:collection_id])
  end

  def update
    accession = Accession.find(params[:id])
    accession.update(accession_params)
    redirect_to accession
  end

  def slew
    @accession = Accession.find(params[:id])
    @collection =  Collection.find(@accession[:collection_id]) 
  end

  def create_slew
    slew = params[:slew_create]
    accession = Accession.find(params[:id])
    max_id = get_max_mlog_id(slew[:collection_id])
    slew_count = slew[:slew_count].to_i
    
    while(slew_count > 0)
      max_id = max_id + 1
      mlog_entry = MlogEntry.new
      mlog_entry[:collection_id] = slew[:collection_id]
      mlog_entry[:accession_id] = slew[:accession_id]
      mlog_entry[:mediatype] = slew[:mediatype]
      mlog_entry[:media_id] = max_id
      mlog_entry[:stock_size_num] =  slew[:stock_size_num]
      mlog_entry[:stock_unit] = slew[:stock_unit]
      mlog_entry[:box_number] = slew[:box_number]
      mlog_entry[:created_by] = current_user[:id]
      mlog_entry[:modified_by] = current_user[:id]
      mlog_entry.save
      slew_count = slew_count - 1
    end
    
    flash[:notice] = "#{slew[:slew_count]} entries added to medialog of type #{MLOG_VOCAB['mediatypes'][slew[:mediatype]]}"
    redirect_to accession

  end

  def box
    @accession = Accession.find(params[:id])
    @collection = Collection.find(@accession[:collection_id]) 
    @mlog = MlogEntry.where(:accession_id => @accession[:id], :box_number => params[:box_id])
    @mlog_entries = @mlog.order(media_id: :asc).page params[:page]
    @type_data = get_type_data(@mlog)
    @total_size = get_total_size(@type_data)    
  end

  def destroy

    accession = Accession.find(params[:id])
    collection = Collection.find(accession.collection_id)
    mlog_entries = MlogEntry.where(:accession_id => accession.id)

    mlog_entries.each do |entry|
      entry.destroy
    end

    accession.destroy
    redirect_to collection

  end

  private 
    def accession_params
      params.require(:accession).permit(:accession_num, :accession_note, :collection_id, :accession_state, :created_by, :modified_by)
    end

    def get_max_mlog_id(col_id)
      mlogs = MlogEntry.where(:collection_id => col_id)

      if mlogs.size != 0  
        ids = Array.new
        mlogs.each do |mlog|
          ids.push mlog[:media_id]
        end

        ids.sort!
        ids.pop
      else
        0
      end
    end  
end
