# built-ins
#
  require 'thread'
  require "uri"
  require 'net/http'
  require 'net/https'
  require 'open-uri'
  require 'fileutils'
  require 'tmpdir'

# libs
#
  module FBomb
    Version = '1.1.0' unless defined?(Version)

    def version
      FBomb::Version
    end

    def libdir(*args, &block)
      @libdir ||= File.expand_path(__FILE__).sub(/\.rb$/,'')
      args.empty? ? @libdir : File.join(@libdir, *args)
    ensure
      if block
        begin
          $LOAD_PATH.unshift(@libdir)
          block.call()
        ensure
          $LOAD_PATH.shift()
        end
      end
    end

    def load(*libs)
      libs = libs.join(' ').scan(/[^\s+]+/)
      FBomb.libdir{ libs.each{|lib| Kernel.load(lib) } }
    end

    extend(FBomb)
  end

## require gems
#
  require 'rubygems'
  require 'tinder'
  require 'yajl'
  require "yajl/json_gem"     ### this *replaces* any other JSON.parse !
  require "yajl/http_stream"  ### we really do need this
  require 'fukung'
  require 'main'
  require 'nokogiri'
  require 'google-search'
  require 'unidecode'
  require 'systemu'
  require 'pry'
  require 'mechanize'
  require 'mime/types'

## load fbomb
#
  FBomb.load %w[
    util.rb
    campfire.rb
    command.rb
  ]

## openssl - STFU!
#
  verbose = $VERBOSE
  begin
    require 'openssl'
    $VERBOSE = nil
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  rescue Object => e
    :STFU
  ensure
    $VERBOSE = verbose
  end

  class Net::HTTP
    require 'net/https'

    module STFU
      def warn(msg)
        #Kernel.warn(msg) unless msg == "warning: peer certificate won't be verified in this SSL session"
      end

      def use_ssl=(flag)
        super
      ensure
        @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    include(STFU)
  end

## global DSL hook
#
  def FBomb(*args, &block)
    FBomb::Command::DSL.evaluate(*args, &block)
  end
