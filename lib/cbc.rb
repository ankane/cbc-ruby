# stdlib
require "fiddle/import"

# modules
require_relative "cbc/model"
require_relative "cbc/version"

module Cbc
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  lib_name =
    if Gem.win_platform?
      # TODO test
      ["CbcSolver.dll"]
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        ["libCbcSolver.dylib", "/opt/homebrew/lib/libCbcSolver.dylib"]
      else
        ["libCbcSolver.dylib"]
      end
    else
      # coinor-libcbc-dev has libCbcSolver.so
      # coinor-libcbc3.1 has libCbcSolver.so.3.1
      # coinor-libcbc3 has libCbcSolver.so.3
      ["libCbcSolver.so", "libCbcSolver.so.3.1", "libCbcSolver.so.3"]
    end
  self.ffi_lib = lib_name

  # friendlier error message
  autoload :FFI, "cbc/ffi"

  def self.lib_version
    FFI.Cbc_getVersion.to_s
  end

  def self.read_lp(filename)
    model = Model.new
    model.read_lp(filename)
    model
  end

  def self.read_mps(filename)
    model = Model.new
    model.read_mps(filename)
    model
  end

  def self.load_problem(**options)
    model = Model.new
    model.load_problem(**options)
    model
  end
end
