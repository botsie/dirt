Sequel.migration do
  up do
    create_table(:status_tickets) do
      primary_key :id
      String :ticket_id, :null=>false, :unique=>true
      String :status_id
    end
  end

  down do
    drop_table(:ticket_status)
  end
end