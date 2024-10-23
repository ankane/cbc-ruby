# Cbc Ruby

[Cbc](https://github.com/coin-or/Cbc) - the mixed-integer programming solver - for Ruby

Check out [Opt](https://github.com/ankane/opt) for a high-level interface

[![Build Status](https://github.com/ankane/cbc-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/ankane/cbc-ruby/actions)

## Installation

First, install Cbc. For Homebrew, use:

```sh
brew install cbc
```

And for Ubuntu, use:

```sh
sudo apt-get install coinor-libcbc3.1 # or coinor-libcbc3
```

Then add this line to your application’s Gemfile:

```ruby
gem "cbc"
```

## Getting Started

*The API is fairly low-level at the moment*

Load a problem

```ruby
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
    col_type: [:integer, :continuous]
  )
```

Solve

```ruby
model.solve
```

Write the problem to an LP or MPS file (LP requires Cbc 2.10+)

```ruby
model.write_lp("hello.lp")
# or
model.write_mps("hello") # adds .mps.gz
```

Read a problem from an LP or MPS file (LP requires Cbc 2.10+)

```ruby
model = Cbc.read_lp("hello.lp")
# or
model = Cbc.read_mps("hello.mps.gz")
```

## Reference

Set the log level (requires Cbc 2.10+)

```ruby
model.solve(log_level: 1) # 0 = off, 3 = max
```

Set the time limit in seconds (requires Cbc 2.10+)

```ruby
model.solve(time_limit: 30)
```

## History

View the [changelog](https://github.com/ankane/cbc-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/cbc-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/cbc-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/cbc-ruby.git
cd cbc-ruby
bundle install
bundle exec rake test
```
