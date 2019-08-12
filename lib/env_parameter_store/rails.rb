module EnvParameterStore
  class Railtie < ::Rails::Railtie

    config.before_configuration { inject_secrets }

    def inject_secrets
			EnvParameterStore.inject(root.join(EnvParameterStore::DEFAULT_ENV_FILENAME))
    end

    def root
      Rails.root || Pathname.new(ENV['RAILS_ROOT'] || Dir.pwd)
    end
  end
end
