
Sequel.migration do 
  change do 
    create_table(:projects) do
      primary_key :id
      String      :name, :null => false
      String      :identifier, :size => 50
    end

    create_table(:pages) do
      primary_key :id
      Integer     :project_id
      String      :name, :size => 50
      String      :content, :text => true
    end
  end
end 