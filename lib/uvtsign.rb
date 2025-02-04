# frozen_string_literal: true

module Uvtsign
  URL_CACHE = ActiveSupport::Cache::MemoryStore.new
  PRODUCT_URL = 'http://85.120.206.58'
  PRODUCT_NAME = 'UVTSign'
  SUPPORT_EMAIL = 'support@e-uvt.ro'
  HOST = ENV.fetch('HOST')

  CERTS = JSON.parse(ENV.fetch('CERTS', '{}'))
  TIMESERVER_URL = ENV.fetch('TIMESERVER_URL', nil)
  VERSION_FILE_PATH = Rails.root.join('.version')

  DEFAULT_URL_OPTIONS = {
    host: HOST,
    protocol: ENV['FORCE_SSL'].present? ? 'https' : 'http'
  }.freeze

  module_function

  def version
    @version ||= VERSION_FILE_PATH.read.strip if VERSION_FILE_PATH.exist?
  end

  def active_storage_public?
    ENV['ACTIVE_STORAGE_PUBLIC'] == 'true'
  end

  def default_pkcs
    @default_pkcs ||= GenerateCertificate.load_pkcs(Uvtsign::CERTS)
  end

  def trusted_certs
    @trusted_certs ||=
      ENV['TRUSTED_CERTS'].to_s.gsub('\\n', "\n").split("\n\n").map do |base64|
        OpenSSL::X509::Certificate.new(base64)
      end
  end

  def default_url_options
    DEFAULT_URL_OPTIONS
  end

  def product_name
    PRODUCT_NAME
  end

  def refresh_default_url_options!
    @default_url_options = nil
  end
end
