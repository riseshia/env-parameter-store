require "env_parameter_store/version"

require "aws-sdk-ssm"
require "json"

module EnvParameterStore
  class Error < StandardError; end

  class NoSuchFileError < Error
    def initialize(filename)
      super("Can not find envfile: #{filename}")
    end
  end

  class InvalidJSONError < Error
    def initialize(filename)
      super("`#{filename}` is not valid json.")
    end
  end

  class InvalidFormatError < Error
    def initialize
      super("Configuration has invalid format. `prefix` (string) and `parameters` (string list) is required.")
    end
  end

  class InvalidParameterError < Error
    def initialize(invalid_parameters)
      subjects = invalid_parameters.map { |s| "`#{s}`" }.join(', ')
      super("Fail to fetch some parameters: #{subjects}.")
    end
  end


  DEFAULT_ENV_FILENAME = ".secret.json".freeze

  class << self
    # Inject secrets from AWS Systems Manager Parameter Store to `ENV`.
    # secrets list is listed on `.secret`.
    # EnvParameterStore will be overwrite if corresponding value exists
    # @param [String] filename
    # @return [Hash] env
    def inject(filename = DEFAULT_ENV_FILENAME)
      filename = File.expand_path(filename.to_s)
      config = load_config(filename)
      secrets = fetch_secrets(config)
      ENV.update(secrets)
    end

    private

    def load_config(filename)
      config_json = JSON.parse(File.read(filename))
      EnvParameterStore::Config.new(config_json)
    rescue Errno::ENOENT
      raise NoSuchFileError.new(filename)
    rescue JSON::ParserError
      raise InvalidJSONError.new(filename)
    end

    def fetch_secrets(config)
      client = Aws::SSM::Client.new
      resp = client.get_parameters(
        names: config.parameter_names,
        with_decryption: true,
      )
      unless resp.invalid_parameters.empty?
        raise InvalidParameterError.new(resp.invalid_parameters)
      end
      resp.parameters.each_with_object({}) do |parameter, secrets|
        key = config.to_name(parameter.name)
        secrets[key] = parameter.value
      end
    end
  end

  class Config
    def initialize(config_json)
      unless config_json.key?('prefix') \
          && config_json.key?('parameters') \
          && config_json.fetch('prefix').is_a?(String) \
          && config_json.fetch('parameters').is_a?(Array) \
          && config_json.fetch('parameters').all? { |key| key.is_a?(String) }
        raise EnvParameterStore::InvalidJSONError.new
      end

      prefix = config_json.fetch('prefix')
      @qualified_names_to_names = config_json.fetch('parameters').each_with_object({}) do |key, table|
        table[prefix + key] = key
      end
    end

    def to_name(qualified_name)
      @qualified_names_to_names.fetch(qualified_name)
    end

    def parameter_names
      @qualified_names_to_names.keys
    end
  end
end

require 'env_parameter_store/rails' if defined?(Rails)
