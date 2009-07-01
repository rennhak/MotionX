migration 5, :format do
  up do
    create_table( :format  ) do
        column( :id, Integer, :serial => true )
        column( :type, String, :size => 10 )
        column( :version, String, :size => 10 )
    end
  end

  down do
    drop_table( :format )
  end
end
