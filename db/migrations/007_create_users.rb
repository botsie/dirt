Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      Boolean :editor
      
    end
  end

  down do
    drop_table(:users)
  end
end