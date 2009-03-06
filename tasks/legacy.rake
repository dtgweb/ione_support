# lib/tasks/legacy.rake
# 
# - prepare all legacy databases with rake db:test:prepare:legacy
# - db:test:*:legacy_db to run any db:test: task on database legacy_db
# 

desc 'Run all unit, functional and integration tests'
task :test_legacy do
  errors = %w(test:units_legacy test:functionals_legacy test:integration_legacy).collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

namespace :test do
  
  task :plugins_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:plugins"].invoke
  end
  
  task :recent_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:recent"].invoke
  end
  Rake::Task['test:recent_legacy'].comment = "Test recent changes"
  
  task :uncommitted_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:uncommited"].invoke
  end
  Rake::Task['test:uncommitted_legacy'].comment = "Test changes since last checkin (only Subversion and Git)"

  task :units_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:units"].invoke
  end
  Rake::Task['test:units_legacy'].comment = "Run the unit tests in test/unit"

  task :functionals_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:functionals"].invoke
  end
  Rake::Task['test:functionals_legacy'].comment = "Run the functional tests in test/functional"

  task :integration_legacy => "db:test:prepare:legacy" do |t|
    Rake::Task["test:integration"].invoke
  end
  Rake::Task['test:integration_legacy'].comment = "Run the integration tests in test/integration"

  task :benchmark_legacy => 'db:test:prepare:legacy' do |t|
    Rake::Task["test:benchmark"].invoke
  end
  Rake::Task['test:benchmark_legacy'].comment = 'Benchmark the performance tests'

  task :profile_legacy => 'db:test:prepare:legacy' do |t|
    Rake::Task["test:profile"].invoke
  end
  Rake::Task['test:profile_legacy'].comment = 'Profile the performance tests'

end

# list your legacy dbs here:
legacy_dbs = %w(support)

def prepend(prefix, array)
  array.collect { |item| prefix + item }
end

namespace :db do
  
  namespace :structure do
    
    legacy_dbs.each do |legacy_db|
      task "dump_#{legacy_db}" => :environment do
        abcs = ActiveRecord::Base.configurations
        case abcs["#{legacy_db}_#{RAILS_ENV}"]["adapter"]
        when "mysql", "oci", "oracle"
          ActiveRecord::Base.establish_connection(abcs["#{legacy_db}_#{RAILS_ENV}"])
          File.open("#{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql", "w+") { |f| f << ActiveRecord::Base.connection.structure_dump }
        when "postgresql"
          ENV['PGHOST']     = abcs["#{legacy_db}_#{RAILS_ENV}"]["host"] if abcs["#{legacy_db}_#{RAILS_ENV}"]["host"]
          ENV['PGPORT']     = abcs["#{legacy_db}_#{RAILS_ENV}"]["port"].to_s if abcs["#{legacy_db}_#{RAILS_ENV}"]["port"]
          ENV['PGPASSWORD'] = abcs["#{legacy_db}_#{RAILS_ENV}"]["password"].to_s if abcs["#{legacy_db}_#{RAILS_ENV}"]["password"]
          search_path = abcs["#{legacy_db}_#{RAILS_ENV}"]["schema_search_path"]
          search_path = "--schema=#{search_path}" if search_path
          `pg_dump -i -U "#{abcs["#{legacy_db}_#{RAILS_ENV}"]["username"]}" -s -x -O -f db/#{legacy_db}_#{RAILS_ENV}_structure.sql #{search_path} #{abcs["#{legacy_db}_#{RAILS_ENV}"]["database"]}`
          raise "Error dumping database" if $?.exitstatus == 1
        when "sqlite", "sqlite3"
          dbfile = abcs["#{legacy_db}_#{RAILS_ENV}"]["database"] || abcs["#{legacy_db}_#{RAILS_ENV}"]["dbfile"]
          `#{abcs["#{legacy_db}_#{RAILS_ENV}"]["adapter"]} #{dbfile} .schema > db/#{legacy_db}_#{"#{legacy_db}_#{RAILS_ENV}"}_structure.sql`
        when "sqlserver"
          `scptxfr /s #{abcs["#{legacy_db}_#{RAILS_ENV}"]["host"]} /d #{abcs["#{legacy_db}_#{RAILS_ENV}"]["database"]} /I /f db\\#{legacy_db}_#{RAILS_ENV}_structure.sql /q /A /r`
          `scptxfr /s #{abcs["#{legacy_db}_#{RAILS_ENV}"]["host"]} /d #{abcs["#{legacy_db}_#{RAILS_ENV}"]["database"]} /I /F db\ /q /A /r`
        when "firebird"
          set_firebird_env(abcs["#{legacy_db}_#{RAILS_ENV}"])
          db_string = firebird_db_string(abcs["#{legacy_db}_#{RAILS_ENV}"])
          sh "isql -a #{db_string} > #{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql"
        else
          raise "Task not supported by '#{abcs["test"]["adapter"]}'"
        end

        begin
          if ActiveRecord::Base.connection.supports_migrations?
            File.open("#{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql", "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
          end
        rescue
          puts "no schema migrations table"
        end
      end
    end
  end
    
  namespace :test do    
    
    namespace :prepare do

      desc "like db:test:prepare plus copies all legacy database structure to the test database" 
      task :legacy => "db:test:prepare" do
        prepend("db:test:clone_structure_", legacy_dbs).each do |task|
          Rake::Task[task].invoke
        end
      end
      
    end
    
    legacy_dbs.each do |legacy_db|
      
      task "purge_#{legacy_db}" => :environment do
        abcs = ActiveRecord::Base.configurations
        case abcs["#{legacy_db}_test"]["adapter"]
        when "mysql"
          ActiveRecord::Base.establish_connection("#{legacy_db}_test")
          ActiveRecord::Base.connection.recreate_database(abcs["#{legacy_db}_test"]["database"], abcs["#{legacy_db}_test"])
        when "postgresql"
          ActiveRecord::Base.clear_active_connections!
          drop_database(abcs["#{legacy_db}_test"])
          create_database(abcs["#{legacy_db}_test"])
        when "sqlite","sqlite3"
          dbfile = abcs["#{legacy_db}_test"]["database"] || abcs["#{legacy_db}_test"]["dbfile"]
          File.delete(dbfile) if File.exist?(dbfile)
        when "sqlserver"
          dropfkscript = "#{abcs["#{legacy_db}_test"]["host"]}.#{abcs["#{legacy_db}_test"]["database"]}.DP1".gsub(/\\/,'-')
          `osql -E -S #{abcs["#{legacy_db}_test"]["host"]} -d #{abcs["#{legacy_db}_test"]["database"]} -i db\\#{dropfkscript}`
          `osql -E -S #{abcs["#{legacy_db}_test"]["host"]} -d #{abcs["#{legacy_db}_test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
        when "oci", "oracle"
          ActiveRecord::Base.establish_connection("#{legacy_db}_test")
          ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        when "firebird"
          ActiveRecord::Base.establish_connection("#{legacy_db}_test")
          ActiveRecord::Base.connection.recreate_database!
        else
          raise "Task not supported by '#{abcs["#{legacy_db}_test"]["adapter"]}'"
        end
      end
      
      task "clone_structure_#{legacy_db}" => [ "db:structure:dump_#{legacy_db}", "db:test:purge_#{legacy_db}" ] do
        abcs = ActiveRecord::Base.configurations
        case abcs["#{legacy_db}_test"]["adapter"]
        when "mysql"
          ActiveRecord::Base.establish_connection("#{legacy_db}_test")
          ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
          IO.readlines("#{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql").join.split("\n\n").each do |table|
            ActiveRecord::Base.connection.execute(table)
          end
        when "postgresql"
          ENV['PGHOST']     = abcs["#{legacy_db}_test"]["host"] if abcs["#{legacy_db}_test"]["host"]
          ENV['PGPORT']     = abcs["#{legacy_db}_test"]["port"].to_s if abcs["#{legacy_db}_test"]["port"]
          ENV['PGPASSWORD'] = abcs["#{legacy_db}_test"]["password"].to_s if abcs["#{legacy_db}_test"]["password"]
          `psql -U "#{abcs["#{legacy_db}_test"]["username"]}" -f #{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql #{abcs["#{legacy_db}_test"]["database"]}`
        when "sqlite", "sqlite3"
          dbfile = abcs["#{legacy_db}_test"]["database"] || abcs["#{legacy_db}_test"]["dbfile"]
          `#{abcs["#{legacy_db}_test"]["adapter"]} #{dbfile} < #{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql`
        when "sqlserver"
          `osql -E -S #{abcs["#{legacy_db}_test"]["host"]} -d #{abcs["#{legacy_db}_test"]["database"]} -i db\\#{legacy_db}_#{RAILS_ENV}_structure.sql`
        when "oci", "oracle"
          ActiveRecord::Base.establish_connection(:test)
          IO.readlines("#{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql").join.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        when "firebird"
          set_firebird_env(abcs["#{legacy_db}_test"])
          db_string = firebird_db_string(abcs["#{legacy_db}_test"])
          sh "isql -i #{RAILS_ROOT}/db/#{legacy_db}_#{RAILS_ENV}_structure.sql #{db_string}"
        else
          raise "Task not supported by '#{abcs["#{legacy_db}_test"]["adapter"]}'"
        end
      end
    end
    
    commands = %w(clone clone_structure)
    commands.each do |command|
      legacy_dbs.each do |legacy_db|
        
        namespace command do
          
          desc "like db:test:#{command} but for #{legacy_db}" 
          task legacy_db do
            config_path = "config/environments" 

            # db:test:clone will complain without this environments file
            #File.copy("#{config_path}/#{RAILS_ENV}.rb", "#{config_path}/#{legacy_db}_development.rb")

            # fake the environment to get the legacy database's structure in the test db
            #backup_env = RAILS_ENV;
            #RAILS_ENV = "#{legacy_db}_development"
            
            Rake::Task["db:test:#{command}_#{legacy_db}"].invoke
            
            # restore
            #File.delete("#{config_path}/#{legacy_db}_development.rb")
            #RAILS_ENV = backup_env;
            
          end
          
        end

      end
    end
  end
end
