migration 2, :update_frequenies  do
  up do
    create_table( :update_frequencies ) do
        column( :id, Integer, :serial => true )
        column( :id_ressource, Integer )
        column( :update_frequency, Integer )
        column( :created_at, DateTime )
        column( :updated_at, DateTime )
    end
  end

  down do
    drop_table( :update_frequencies )
  end
end
