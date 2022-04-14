module Cbc
  module FFI
    extend Fiddle::Importer

    libs = Array(Cbc.ffi_lib).dup
    begin
      dlload Fiddle.dlopen(libs.shift)
    rescue Fiddle::DLError => e
      retry if libs.any?
      raise e
    end

    # https://github.com/coin-or/Cbc/blob/releases/2.9.9/Cbc/src/Cbc_C_Interface.h

    OBJ_SENSE = {
      minimize: 1,
      ignore: 0,
      maximize: -1
    }

    STATUS = {
      -1 => :not_started,
      0 => :finished,
      1 => :stopped,
      2 => :abandoned,
      5 => :interrupted
    }

    SECONDARY_STATUS = {
      -1 => :unset,
      0 => :completed,
      1 => :infeasible,
      2 => :stopped_gap,
      3 => :stopped_nodes,
      4 => :stopped_time,
      5 => :stopped_user,
      6 => :stopped_solutions,
      7 => :unbounded,
      8 => :stopped_iterations
    }

    typealias "CoinBigIndex", "int"

    # version info
    extern "char * Cbc_getVersion(void)"

    # load models
    extern "Cbc_Model * Cbc_newModel(void)"
    extern "void Cbc_loadProblem(Cbc_Model *model, int numcols, int numrows, CoinBigIndex *start, int *index, double *value, double *collb, double *colub, double *obj, double *rowlb, double *rowub)"
    extern "void Cbc_setObjSense(Cbc_Model *model, double sense)"
    extern "int Cbc_isInteger(Cbc_Model * model, int i)"
    extern "void Cbc_setContinuous(Cbc_Model *model, int iColumn)"
    extern "void Cbc_setInteger(Cbc_Model *model, int iColumn)"
    extern "void Cbc_deleteModel(Cbc_Model *model)"

    # read and write
    extern "int Cbc_readMps(Cbc_Model *model, char *filename)"
    extern "void Cbc_writeMps(Cbc_Model *model, char *filename)"

    # solve
    extern "int Cbc_getNumCols(Cbc_Model *model)"
    extern "int Cbc_getNumRows(Cbc_Model *model)"
    extern "int Cbc_solve(Cbc_Model *model)"
    extern "double * Cbc_getColSolution(Cbc_Model *model)"
    extern "int Cbc_isAbandoned(Cbc_Model *model)"
    extern "int Cbc_isProvenOptimal(Cbc_Model *model)"
    extern "int Cbc_isProvenInfeasible(Cbc_Model *model)"
    extern "int Cbc_isContinuousUnbounded(Cbc_Model *model)"
    extern "double Cbc_getObjValue(Cbc_Model *model)"
    extern "int Cbc_status(Cbc_Model *model)"
    extern "int Cbc_secondaryStatus(Cbc_Model *model)"

    if Gem::Version.new(FFI.Cbc_getVersion.to_s) >= Gem::Version.new("2.10.0")
      extern "int Cbc_readLp(Cbc_Model *model, char *filename)"
      extern "void Cbc_writeLp(Cbc_Model *model, char *filename)"

      extern "double Cbc_getMaximumSeconds(Cbc_Model *model)"
      extern "void Cbc_setMaximumSeconds(Cbc_Model *model, double maxSeconds)"
      extern "int Cbc_getLogLevel(Cbc_Model *model)"
      extern "void Cbc_setLogLevel(Cbc_Model *model, int logLevel)"
    end
  end
end
