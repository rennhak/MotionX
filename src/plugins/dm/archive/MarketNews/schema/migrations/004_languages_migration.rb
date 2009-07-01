migration 4, :languages do

  up do
    create_table( :languages  ) do
        column( :id, Integer, :serial => true )
        column( :short, String, :size => 15 )
        column( :long, String, :size => 30 )
    end
  end

  down do
    drop_table( :languages )
  end

end
