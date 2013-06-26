Sequel.migration do
  up do
    create_table(:rt_statuses) do
      primary_key :id
      String :rt_status_name, :null=>false
    end
  end

  down do
    drop_table(:statuses)
  end
end