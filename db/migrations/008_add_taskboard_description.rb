
Sequel.migration do 
  change do 
    alter_table(:projects) do
      add_column :taskboard, :text 
    end
  end
end 