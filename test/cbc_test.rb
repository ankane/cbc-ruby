require_relative "test_helper"

class CbcTest < Minitest::Test
  def test_lib_version
    assert_match(/\A\d+\.\d+\.\d+\z/, Cbc.lib_version)
  end

  def test_load_problem_mip
    model =
      Cbc.load_problem(
        sense: :minimize,
        start: [0, 3, 6],
        index: [0, 1, 2, 0, 1, 2],
        value: [2, 3, 2, 2, 4, 1],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        obj: [8, 10],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30],
        col_type: [:integer, :integer]
      )

    if below210?
      error = assert_raises(Cbc::Error) do
        model.write_lp("/tmp/test.lp")
      end
      assert_equal "This feature requires Cbc 2.10.0+", error.message
    else
      model.write_lp("/tmp/test.lp")
      assert_equal File.binread("test/support/test.lp"), File.binread("/tmp/test.lp")
    end

    # adds mps.gz
    model.write_mps("/tmp/test")
    assert File.exist?("/tmp/test.mps.gz")

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:objective]
    assert_elements_in_delta [4, 0], res[:primal_col]
  end

  def test_load_problem_lp
    model =
      Cbc.load_problem(
        sense: :minimize,
        start: [0, 3, 6],
        index: [0, 1, 2, 0, 1, 2],
        value: [2, 3, 2, 2, 4, 1],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        obj: [8, 10],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30],
        col_type: [:continuous, :continuous]
      )

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 31.2, res[:objective]
    assert_elements_in_delta [2.4, 1.2], res[:primal_col]
  end

  def test_read_mps
    model = Cbc.read_mps("test/support/test.mps")
    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:objective]
    assert_elements_in_delta [4, 0], res[:primal_col]
  end

  def test_read_mps_gz
    model = Cbc.read_mps("test/support/test.mps.gz")
    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:objective]
    assert_elements_in_delta [4, 0], res[:primal_col]
  end

  def test_read_lp
    skip if below210?

    model = Cbc.read_lp("test/support/test.lp")
    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:objective]
    assert_elements_in_delta [4, 0], res[:primal_col]
  end

  def test_time_limit
    skip if below210?

    model = Cbc.read_mps("test/support/test.mps")
    res = model.solve(time_limit: 0.000001)
    assert_equal :stopped_time, res[:status]
  end

  private

  def below210?
    Gem::Version.new(Cbc.lib_version) < Gem::Version.new("2.10.0")
  end
end
