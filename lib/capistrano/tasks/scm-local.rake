namespace :local do

  def local_strategy
    strategies = {:default=>Capistrano::Local::DefaultStrategy, :archive=>Capistrano::Local::ArchiveStrategy}

    m = fetch(:local_strategy ? :local_strategy : :default)
    unless m.is_a?(Module)
      abort "Invalid local_strategy: " + m.to_s unless strategies.include?(m)
      m = strategies[m]
    end

    @local_strategy ||= Capistrano::Local.new(self, m)
  end

  desc 'Check that the source is reachable'
  task :check do
    run_locally do
        exit 1 unless local_strategy.check
    end
  end

  desc 'Copy repo to releases'
  task :create_release do
    on release_roles :all do
      within releases_path do
        execute :mkdir, '-p', release_path
      end
    end
    local_strategy.release
  end
end