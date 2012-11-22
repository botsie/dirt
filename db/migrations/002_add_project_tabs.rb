
Sequel.migration do 
  change do 
    alter_table(:projects) do
      add_column :tab_spec, String, :null=>false, :default=>%q([{"caption":"Index", "page":"index"}])
    end
  end
end 