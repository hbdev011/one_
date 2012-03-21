namespace :db do
	`mysql -u root -p < db/sql/config_2.sql`
	software_update
end


