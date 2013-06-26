Sequel.migration do
  up do
    create_table(:statuses) do
      primary_key :id
      String :status_name, :null=>false
      Integer :project_id
      Integer :rt_status_id
      Integer :max_tickets
    end
  end

  down do
    drop_table(:statuses)
  end
end