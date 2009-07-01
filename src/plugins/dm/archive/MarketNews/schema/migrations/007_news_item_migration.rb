include DataMapper::Types

migration 7, :news_item do
  up do
    create_table( :news_item  ) do
        column( :id, Integer, :serial => true )
        column( :id_ressource, Integer )
        column( :title, String, :size => 40 )
        column( :description, String, :size => 200 )
        column( :completed, Boolean ) 
        column( :created_at, DateTime )
        column( :updated_at, DateTime )
    end
  end

  down do
    drop_table( :news_item )
  end
end
