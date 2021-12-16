.PHONY: all build check tags

all: build

build:
	bazel build //main:sorbet --config=dbg --verbose_failures

build-mac:
	bazel build //main:sorbet --config=release-mac

build-sanitize:
	bazel build //main:sorbet --config=sanitize

build-orig:
	bazel build //main:sorbet-orig --config=dbg --verbose_failures

build-realmain:
	bazel build //main:realmain --config=dbg --verbose_failures

check:
	bazel test --config=dbg	//...

check-parser:
	bazel test --config=dbg //test:whitequark_parser_tests

check-srb:
	bazel test --config=dbg //gems/sorbet/test/snapshot

clean:
	bazel clean --expunge

format:
	./tools/scripts/format_cxx.sh

tags:
	ctags .

check-cli:
	bazel query 'tests(//test/cli)' | xargs bazel test --config=dbg

check-fwd:
	# pos
	bazel test --config=dbg //test:test_PosTests/testdata/desugar/forward_args
	bazel test --config=dbg //test:test_PosTests/testdata/resolver/forward_args
	# fwd
	bazel test --config=dbg //test:test_LSPTests/testdata/desugar/forward_args
	bazel test --config=dbg //test:test_LSPTests/testdata/resolver/forward_args

check-pm:
	bazel query 'tests(//test)' | grep pattern_matching | xargs bazel test --config=dbg
	bazel query 'tests(//...)' 2>/dev/null | grep 'test_pattern_matching' | xargs bazel test --config=dbg

check-ra:
	bazel query 'tests(//...)' | grep "requires\(_\|-\)ancestor" | xargs bazel test --config=dbg
