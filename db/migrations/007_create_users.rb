Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :uname
      Boolean :editor
      String :pic_url
      String :team_name
    end
  end

  down do
    drop_table(:users)
  end
end