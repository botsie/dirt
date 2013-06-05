Sequel.migration do
  up do
    create_table(:statuses) do
      primary_key :id
      String :status_name, :null=>false
      String :project_id
    end
  end

  down do
    drop_table(:statuses)
  end
end