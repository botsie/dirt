Sequel.migration do
  up do
    create_table(:status_tickets) do
      primary_key :id
      Integer :ticket_id, :null=>false, :unique=>true
      Integer :status_id
    end
  end

  down do
    drop_table(:ticket_status)
  end
end