class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include ApplicationHelper
  before_action :authenticate_user!

  class AspaceClient
    
    @@client_config = ArchivesSpace::Configuration.new({
      base_uri: ASPACE_CONFIG["uri"],
      base_repo: "",
      username: ASPACE_CONFIG["username"],
      password: ASPACE_CONFIG["password"],
      page_size: 50,
      throttle: 0,
      verify_ssl: false,
    })

    def get_accession_by_title(repo, title)
      client = ArchivesSpace::Client.new(@@client_config).login
      response = client.get('repositories/' + repo.to_s + '/search?type[]=accession&page=1&aq={"query":{"field":"title","value":"' + title + '", "jsonmodel_type":"field_query","negated":false,"literal":true}}')
      @results = Array.new

      response.parsed['results'].each do |result|
        
        json = MultiJson.load(result['json'])
        @results.push (result['id']  + " " + (json['id_0'] || "")  + (json['id_1'] || "") + (json['id_2'] || "") +  (json['id_3'] || "") + ": " + json['title']) 
      end

      @results

    end

  end

end