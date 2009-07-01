migration 6, :ressource  do
  up do
    create_table( :ressource  ) do
        column( :id, Integer, :serial => true )
        column( :id_category, Integer )
        column( :id_languages, Integer )
        column( :id_format, Integer )
        column( :title, String, :size => 40 )
        column( :subtitle, String, :size => 40 )
        column( :uri, String, :size => 255 )
        column( :description, String, :size => 200 )
        column( :update_frequency, Integer )
        column( :created_at, DateTime )
        column( :updated_at, DateTime )
    end
  end

  down do
    drop_table( :ressource )
  end

end
