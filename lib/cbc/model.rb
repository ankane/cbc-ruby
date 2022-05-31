module Cbc
  class Model
    def initialize
      @model = FFI.Cbc_newModel
      ObjectSpace.define_finalizer(self, self.class.finalize(@model))

      @below210 = Gem::Version.new(Cbc.lib_version) < Gem::Version.new("2.10.0")
      FFI.Cbc_setLogLevel(model, 0) unless @below210
    end

    def load_problem(sense:, start:, index:, value:, col_lower:, col_upper:, obj:, row_lower:, row_upper:, col_type:)
      start_size = start.size
      index_size = index.size
      num_cols = col_lower.size
      num_rows = row_lower.size

      FFI.Cbc_loadProblem(
        model, num_cols, num_rows,
        big_index_array(start, start_size), int_array(index, index_size), double_array(value, index_size),
        double_array(col_lower, num_cols), double_array(col_upper, num_cols), double_array(obj, num_cols),
        double_array(row_lower, num_rows), double_array(row_upper, num_rows)
      )
      FFI.Cbc_setObjSense(model, FFI::OBJ_SENSE.fetch(sense))

      if col_type.size != num_cols
        raise ArgumentError, "wrong size (given #{value.size}, expected #{size})"
      end

      col_type.each_with_index do |v, i|
        case v
        when :integer
          FFI.Cbc_setInteger(model, i)
        when :continuous
          FFI.Cbc_setContinuous(model, i)
        else
          raise ArgumentError, "Unknown col_type"
        end
      end
    end

    def read_lp(filename)
      check_version
      check_status FFI.Cbc_readLp(model, filename)
    end

    def read_mps(filename)
      check_status FFI.Cbc_readMps(model, filename)
    end

    def write_lp(filename)
      check_version
      FFI.Cbc_writeLp(model, filename)
    end

    def write_mps(filename)
      FFI.Cbc_writeMps(model, filename)
    end

    def solve(log_level: nil, time_limit: nil)
      with_options(log_level: log_level, time_limit: time_limit) do
        # do not check status
        FFI.Cbc_solve(model)
      end

      num_cols = FFI.Cbc_getNumCols(model)

      status = FFI::STATUS[FFI.Cbc_status(model)]
      secondary_status = FFI::SECONDARY_STATUS[FFI.Cbc_secondaryStatus(model)]

      ret_status =
        case status
        when :not_started
          if FFI.Cbc_isInitialSolveProvenOptimal(model) != 0
            :optimal
          elsif FFI.Cbc_isInitialSolveProvenPrimalInfeasible(model) != 0
            :infeasible
          else
            secondary_status
          end
        when :finished
          if FFI.Cbc_isProvenOptimal(model) != 0
            :optimal
          elsif FFI.Cbc_isProvenInfeasible(model) != 0
            :infeasible
          else
            secondary_status
          end
        else
          secondary_status
        end

      {
        status: ret_status,
        objective: FFI.Cbc_getObjValue(model),
        primal_col: read_double_array(FFI.Cbc_getColSolution(model), num_cols)
      }
    end

    def self.finalize(model)
      # must use proc instead of stabby lambda
      proc { FFI.Cbc_deleteModel(model) }
    end

    private

    def model
      @model
    end

    def check_status(status)
      if status != 0
        raise Error, "Bad status: #{status}"
      end
    end

    def check_version
      if @below210
        raise Error, "This feature requires Cbc 2.10.0+"
      end
    end

    def double_array(value, size)
      base_array(value, size, "d")
    end

    def int_array(value, size)
      base_array(value, size, "i!")
    end
    alias_method :big_index_array, :int_array

    def base_array(value, size, format)
      if value.size != size
        # TODO add variable name to message
        raise ArgumentError, "wrong size (given #{value.size}, expected #{size})"
      end
      Fiddle::Pointer[value.pack("#{format}#{size}")]
    end

    def read_double_array(ptr, size)
      ptr[0, size * Fiddle::SIZEOF_DOUBLE].unpack("d#{size}")
    end

    def with_options(log_level:, time_limit:)
      if log_level
        check_version
        previous_log_level = FFI.Cbc_getLogLevel(model)
        FFI.Cbc_setLogLevel(model, log_level)
      end

      if time_limit
        check_version
        previous_time_limit = FFI.Cbc_getMaximumSeconds(model)
        FFI.Cbc_setMaximumSeconds(model, time_limit)
      end

      yield
    ensure
      FFI.Cbc_setLogLevel(model, previous_log_level) if previous_log_level
      FFI.Cbc_setMaximumSeconds(model, previous_time_limit) if previous_time_limit
    end
  end
end
