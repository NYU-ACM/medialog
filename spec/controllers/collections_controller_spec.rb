require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  
  render_views

  let(:valid_user) { { 
    "email" => "me@home.com", 
    "password" => "watching the telly",
    "admin" => false } }	

  let(:valid_col_attributes) { { 
    "id" => 55,
    "title" => "test_collection", 
    "partner_code" => "fa",
    "collection_code" => "mssxxx" } }

    let(:valid_accession_attributes) { {
    "id" => 1,
    "accession_num" => "1999.99",
    "collection_id" => 55
  } }

  let(:valid_session) { {} }


  let(:user) { User.create! valid_user }

  before { sign_in user }

  describe "GET index" do
    it "assigns all collections as @collections" do
      col = Collection.create! valid_col_attributes
      get :index, {}, valid_session
      assigns(:collections).should eq([col])
    end
  end

  describe "GET show" do
    it "assigns the requested collection as @collection" do
      collection = Collection.create! valid_col_attributes
      get :show, {:id => collection.to_param}, valid_session
      assigns(:collection).should eq(collection)
    end
  end
  
end