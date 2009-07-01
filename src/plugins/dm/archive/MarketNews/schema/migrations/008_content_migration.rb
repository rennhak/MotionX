migration 8, :content  do
  up do
    create_table( :content  ) do
        column( :id, Integer, :serial => true )
        column( :id_news_item, Integer )
        column( :data, String, :size => 10000 )
        column(:created_at, DateTime)
        column(:updated_at, DateTime)
    end
  end

  down do
    drop_table( :content )
  end
end
