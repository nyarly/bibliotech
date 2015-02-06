Gem::Specification.new do |spec|
  spec.name		= "bibliotech"
  #{MAJOR: incompatible}.{MINOR added feature}.{PATCH bugfix}-{LABEL}
  spec.version		= "0.4.1"
  author_list = { "Evan Dorn" => 'evan@lrdesign.com', "Judson Lester" => 'judson@lrdesign.com' }
  spec.authors		= author_list.keys
  spec.email		= spec.authors.map {|name| author_list[name]}
  spec.summary		= ""
  spec.description	= <<-EndDescription
    Tools for managing SQL backups and local/remote database
  EndDescription

  spec.rubyforge_project= spec.name.downcase
  spec.homepage        = ""
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Do this: y$@"
  # !!find lib bin doc spec spec_help -not -regex '.*\.sw.' -type f 2>/dev/null
  spec.files		= %w[
    default_configuration/config.yaml
    lib/bibliotech/builders.rb
    lib/bibliotech/builders/database.rb
    lib/bibliotech/builders/gzip.rb
    lib/bibliotech/builders/file.rb
    lib/bibliotech/builders/postgres.rb
    lib/bibliotech/builders/mysql.rb
    lib/bibliotech/config.rb
    lib/bibliotech/logger.rb
    lib/bibliotech/command_runner.rb
    lib/bibliotech/command_generator.rb
    lib/bibliotech/rake_lib.rb
    lib/bibliotech/compression.rb
    lib/bibliotech/compression/bzip2.rb
    lib/bibliotech/compression/gzip.rb
    lib/bibliotech/compression/sevenzip.rb
    lib/bibliotech/backups/scheduler.rb
    lib/bibliotech/backups/pruner.rb
    lib/bibliotech/backups/prune_list.rb
    lib/bibliotech/backups/file_record.rb
    lib/bibliotech/application.rb
    lib/bibliotech/cli.rb
    lib/bibliotech/railtie.rb
    lib/bibliotech.rb
    bin/bibliotech
    spec/spec_helper.rb
    spec/bibliotech/config_spec.rb
    spec/bibliotech/command_generator/postgres_spec.rb
    spec/bibliotech/command_generator/mysql_spec.rb
    spec/bibliotech/backup_pruner_spec.rb
    spec/bibliotech/compression_spec.rb
    spec/bibliotech/compression/bzip2_spec.rb
    spec/bibliotech/compression/sevenzip_spec.rb
    spec/bibliotech/compression/bunzip2_spec.rb
    spec/bibliotech/compression/gzip_spec.rb
    spec/bibliotech/backup_scheduler_spec.rb
    spec/bibliotech/command_generator_spec.rb
    spec/bibliotech/command_runner_spec.rb
  ]


  spec.test_file        = "spec/gem_test_suite.rb"
  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.executables = %w{ bibliotech }

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  spec.add_dependency("caliph", "~> 0.3.1")
  spec.add_dependency("mattock", "~> 0.9.0")
  spec.add_dependency("valise", "~> 1.1.4")
  spec.add_dependency("thor", "~> 0.19.1")

  #spec.post_install_message = "Thanks for installing my gem!"
end
