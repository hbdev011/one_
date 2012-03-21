class ActiveRecord::ConnectionAdapters::MysqlAdapter
	 def import_sql(file)
		   conf = ActiveRecord::Base.configurations[RAILS_ENV]   
		   sql_file = File.join(File.join(File.dirname(__FILE__), "sql" ), "#{file}.sql")
		   cmd_line = "mysql -h localhost -D config_demo --user=root --password=root < "+sql_file
	 end 
end 
