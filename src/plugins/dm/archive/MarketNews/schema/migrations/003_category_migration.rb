migration 3, :category  do
  up do
    create_table( :category  ) do
        column( :id, Integer, :serial => true )
        column( :type, String, :size => 70 )
    end
  end

  down do
    drop_table( :category )
  end
end
