# frozen_string_literal: true
# typed: true

require 'benchmark'
require 'thor'

require_relative '../lib/sorbet-runtime'

module SorbetBenchmarks
  class CLI < Thor
    class_option :checked_level, type: :string, default: "always"
    class_option :no_op_tlet, type: :boolean, default: false
    class_option :iterations_of_block, type: :numeric, default: 1_000_000
    class_option :iterations_in_block, type: :numeric, default: 2

    desc "vanilla_ruby_method_call", "Benchmark Vanilla Ruby Method Call"
    def vanilla_ruby_method_call
      benchmark.vanilla_ruby_method_call
    end

    desc "vanilla_ruby_is_a", "Benchmark Vanilla Ruby is_a?"
    def vanilla_ruby_is_a
      benchmark.vanilla_ruby_is_a
    end

    no_commands do
      def configure_runtime!
        case options[:checked_level]
        when "never"
          T::Configuration.default_checked_level = :never
        else
          T::Configuration.default_checked_level = :always
        end
        # T::Configuration.no_op_tlet! if options[:no_op_tlet]
      end

      def benchmark
        configure_runtime!
        Typecheck.new(
          iterations_of_block: options[:iterations_of_block],
          iterations_in_block: options[:iterations_in_block]
        )
      end
    end
  end

  class Typecheck
    extend T::Sig

    class Example; end

    def initialize(iterations_of_block:, iterations_in_block:)
      @iterations_of_block = iterations_of_block
      @iterations_in_block = iterations_in_block
    end

    def time_block(&blk)
      1_000.times(&blk) # warmup

      GC.start
      GC.disable

      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @iterations_of_block.times(&blk)
      duration_s = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

      GC.enable

      puts duration_s
    end

    def vanilla_ruby_method_call
      time_block do
        unchecked_param(0)
        unchecked_param(1)
        unchecked_param(2)
        unchecked_param(3)
        unchecked_param(nil)
        unchecked_param(0)
        unchecked_param(1)
        unchecked_param(2)
        unchecked_param(3)
        unchecked_param(nil)
      end
    end

    def vanilla_ruby_is_a
      time_block do
        0.is_a?(Integer)
        1.is_a?(Integer)
        'str'.is_a?(Integer)
        nil.is_a?(Integer)
        false.is_a?(Integer)
        0.is_a?(Integer)
        1.is_a?(Integer)
        'str'.is_a?(Integer)
        nil.is_a?(Integer)
        false.is_a?(Integer)
      end
    end

      # type = T::Utils.coerce(Integer)
      # time_block("T::Types::Simple#valid?", iterations_in_block: 10) do
      #   type.valid?(0)
      #   type.valid?(1)
      #   type.valid?(2)
      #   type.valid?(3)
      #   type.valid?(nil)
      #   type.valid?(0)
      #   type.valid?(1)
      #   type.valid?(2)
      #   type.valid?(3)
      #   type.valid?(nil)
      # end

      # type = T::Utils.coerce(T.nilable(Integer))
      # time_block("T::Types::Union#valid?", iterations_in_block: 10) do
      #   type.valid?(0)
      #   type.valid?(1)
      #   type.valid?(2)
      #   type.valid?(nil)
      #   type.valid?(false)
      #   type.valid?(0)
      #   type.valid?(1)
      #   type.valid?(2)
      #   type.valid?(nil)
      #   type.valid?(false)
      # end

      # time_block("T.let(..., Integer)") do
      #   T.let(0, Integer)
      #   T.let(1, Integer)
      # end

      # time_block("sig {params(x: Integer).void}") do
      #   integer_param(0)
      #   integer_param(1)
      # end

      # time_block("T.let(..., T.nilable(Integer))") do
      #   T.let(nil, T.nilable(Integer))
      #   T.let(1, T.nilable(Integer))
      # end

      # time_block("sig {params(x: T.nilable(Integer)).void}") do
      #   nilable_integer_param(nil)
      #   nilable_integer_param(1)
      # end

      # example = Example.new
      # time_block("T.let(..., Example)") do
      #   T.let(example, Example)
      #   T.let(example, Example)
      # end

      # time_block("sig {params(x: Example).void}") do
      #   application_class_param(example)
      #   application_class_param(example)
      # end

      # time_block("T.let(..., T.nilable(Example))") do
      #   T.let(nil, T.nilable(Example))
      #   T.let(example, T.nilable(Example))
      # end

      # time_block("sig {params(x: T.nilable(Example)).void}") do
      #   nilable_application_class_param(nil)
      #   nilable_application_class_param(example)
      # end

      # time_block("sig {params(s: Symbol, x: Integer, y: Integer).void} (with kwargs)") do
      #   arg_plus_kwargs(:foo, x: 1, y: 2)
      #   arg_plus_kwargs(:bar, x: 1)
      # end

      # time_block(".bind(example).call") do
      #   Object.instance_method(:class).bind(example).call
      # end

      # if T::Configuration::AT_LEAST_RUBY_2_7
      #   time_block(".bind_call(example)") do
      #     Object.instance_method(:class).bind_call(example)
      #   end

      #   time_block("if AT_LEAST_RUBY_2_7; .bind_call(example); end") do
      #     if T::Configuration::AT_LEAST_RUBY_2_7
      #       Object.instance_method(:class).bind_call(example)
      #     else
      #       raise "must be run on 2.7"
      #     end
      #   end
      # else
      #   puts 'skipping UnboundMethod#bind_call tests (re-run on Ruby 2.7+)'
      # end
    # end

    sig {params(x: Integer).void.checked(:never)}
    def unchecked_param(x); end

    sig {params(x: Integer).void}
    def self.integer_param(x); end

    sig {params(x: T.nilable(Integer)).void}
    def self.nilable_integer_param(x); end

    sig {params(x: Example).void}
    def self.application_class_param(x); end

    sig {params(x: T.nilable(Example)).void}
    def self.nilable_application_class_param(x); end

    sig {params(s: Symbol, x: Integer, y: Integer).void}
    def self.arg_plus_kwargs(s, x:, y: 0); end
  end
end

SorbetBenchmarks::CLI.start(ARGV)