# frozen_string_literal: true
# typed: true

require 'benchmark'
require_relative '../lib/sorbet-runtime'

def parse_duration(duration, iterations_of_block:, iterations_in_block:)
  ns_per_iter = duration * 1_000_000_000 / (iterations_of_block * iterations_in_block)
  duration_str = ns_per_iter >= 1000 ? "#{(ns_per_iter / 1000).round(3)} μs" : "#{ns_per_iter.round(3)} ns"
  duration_str
end

def print_opts(hash)
  hash.map{|k,v| "--#{k}=#{v}"}.join(" ")
end

times = 5
iterations_of_block = 1_000_000
iterations_in_block = 2

benchmarks = {
  "Vanilla Ruby method call": {
    cmd: "vanilla_ruby_method_call",
    opts: {
      "iterations-of-block": 1_000_000,
      "iterations-in-block": 2
    }
  },

  "Vanilla Ruby is_a?": {
    cmd: "vanilla_ruby_is_a",
    opts: {
      "iterations-of-block": 1_000_000,
      "iterations-in-block": 10
    }
  },
}

variations = {
  "always": {
    "checked-level": "always"
  },
  "never": {
    "checked-level": "never"
  },
  "no-op-tlet": {
    "checked-level": "always",
    "no-op-tlet": "true"
  },
}

benchmarks.each do |name, bench|
  puts "\n#{name}"

  variations.each do |name, opts|
    durations = []

    print name, "\t"
    times.times do
      duration = `bundle exec ruby bench/options.rb #{bench[:cmd]} #{print_opts(opts)} #{print_opts(bench[:opts])}`.to_f
      durations << duration
      print parse_duration(duration, iterations_of_block: iterations_of_block, iterations_in_block: iterations_in_block), "\t"
    end

    avg_duration = durations.sum / durations.size
    puts "AVG: #{parse_duration(avg_duration, iterations_of_block: iterations_of_block, iterations_in_block: iterations_in_block)}"
  end
end