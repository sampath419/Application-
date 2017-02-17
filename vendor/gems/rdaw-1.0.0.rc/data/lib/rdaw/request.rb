# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

module Rdaw::Request
  def self.get_hash(url, logger)
    request             = Net::HTTP.new(url.host, url.port)
    request.use_ssl     = true
    request.verify_mode = Rdaw.const_defined?('SSL_VERIFY_MODE') ? SSL_VERIFY_MODE : OpenSSL::SSL::VERIFY_PEER

    started_at = Time.now
    begin
      response = request.get url.request_uri
    rescue Timeout::Error
      logger.error("[rdaw] validation request timed out after #{request.read_timeout} sec.")
      return denied
    end
    ended_at = Time.now
    logger.debug("[rdaw] validation roundtrip complete in #{ended_at - started_at}ms.")

    begin
      response.body.force_encoding 'utf-8'
    rescue NoMethodError
      # ruby < 1.9
    end

    Hash.new.tap do |h|
      response.body.each_line do |line|
        key, value = line.split('=')
        if key.blank? || value.blank?
          logger.debug("[rdaw] ignoring malformed response line: #{line}.")
        else
          h[key] = value.rstrip
        end
      end # each_line
    end # Hash.new
  end
end # Rdaw::Request
