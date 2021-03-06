json.array!(@mlog_entries) do |mlog_entry|
  json.extract! mlog_entry, :id, :partner_code, :collection_code, :accession_num, :media_id, :mediatype, :manufacturer, :manufacturer_serial, :label_text, :media_note, :photo_url, :image_filename, :interface, :imaging_software, :hdd_interface, :imaging_success, :interpretation_success, :imaged_by, :imaging_note, :image_format, :encoding_scheme, :partition_table_format, :number_of_partitions, :filesystem, :has_dfxml, :has_ftk_csv, :image_size_bytes, :md5_checksum, :sha1_checksum, :date_imaged, :date_ftk_loaded, :date_metadata_extracted, :date_photographed, :date_qc, :date_packaged, :date_transferred
  json.url mlog_entry_url(mlog_entry, format: :json)
end
