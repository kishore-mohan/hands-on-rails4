namespace :bcdb do
  desc "Generate all skeleton configuration files for this environment"
  task :gen_config => [:gen_db_config, :gen_ma_config];

  desc "Generate bcdatabase database configuration files for this environment"
  task :gen_db_config do
    filename = case Rails.env
    when 'development', 'test'
      "#{ENV['HOME']}/.rails4_bcdatabase/local_mysql.yml"
    when 'production'
      "#{ENV['HOME']}/.rails4_bcdatabase/#{Rails.env}_mysql.yml"
    else
      $stderr.puts "Don't know how to generate a bcdatabase skeleton for env '#{Rails.env}'."
      exit(2)
    end

    if File.exist?(filename)
      $stderr.puts "You already have a bcdatabase configuration for this env:\n  #{filename}.\nMove it out of the way or delete it if you want to generate a new skeleton.\n\n"
      next
    end

    yml = case Rails.env
    when 'development', 'test'
      <<-YML
defaults:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  username: MY_LOCAL_USERNAME
  password: MY_LOCAL_PASSWORD
  socket: /var/run/mysqld/mysqld.sock

rails4_review:
  database: movie_review_development

rails4_review_test:
  database: rails4_review_test
      YML
    when 'production'
      <<-YML
defaults:
  adapter: mysql2
  encoding: utf8
  username: #{Rails.env.upcase}_USERNAME
  password: #{Rails.env.upcase}_PASSWORD
  host: #{Rails.env.upcase}_HOST
  port: 3306

rails4_review_#{Rails.env}:
  reconnect: false
  pool: 20
      YML
    end

    mkdir_p File.dirname(filename)
    File.open(filename, 'w') { |f| f.puts yml }
    $stderr.puts "Wrote bcdatabase skeleton for #{Rails.env}:\n  #{filename}.\nEdit it to add appropriate configuration details.\n\n"
  end

  desc "Generate the movie_review external settings file"
  task :gen_ma_config do
    require 'securerandom'

    filename = "#{ENV['HOME']}/.bcdatabase/rails4_review.yml"

    if File.exist?(filename)
      $stderr.puts "You already have an external settings file:\n  #{filename}\nEdit it instead of generating a new one.\n\n"
      next
    end

    envs_for_keys = case Rails.env
    when 'test', 'development'
      %w(development test)
    else
      [Rails.env]
    end

    contents = envs_for_keys.each_with_object({}) do |env, h|
      h[env] = { 'symmetric_encryption_key' => SecureRandom.urlsafe_base64(32) }
    end

    mkdir_p File.dirname(filename)
    File.open(filename, 'w') { |f| f.puts contents.to_yaml }
    $stderr.puts "Wrote external settings file with generated secrets:\n  #{filename}\n\n"
  end

end
