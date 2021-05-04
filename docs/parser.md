# Parser

Sorbet's Ruby parser is based on [Whitequark](https://github.com/whitequark/parser/tree/master/lib/parser).
The source of the parser can be found under `third_party/parser/`.

## Updating Sorbet parser to support new Ruby syntax

This section explains how to perform the required changes on Sorbet to support new syntax introduced
by a new Ruby version.

### Importing Whitequark parser tests

Whitequark comes with an [extensive test suite](https://github.com/whitequark/parser/tree/master/test)
we can import to test Sorbet parser to check its behaviour against new Ruby syntax.

We use the `tools/scripts/import_whitequark.sh` to import Whitequark tests inside Sorbet:

1. Change the value of the `TARGET_RUBY_VERSION` constant to the Ruby version you're targeting.
2. Change the value of the `REF` constant to the commit sha of the last changes made on Whitequark
   corresponding to the Ruby version you're targeting.
3. Add the `racc` command for your version (replace `XX` by the targeted version):
   `bundle exec racc --superclass=Parser::Base lib/parser/rubyXX.y -o lib/parser/rubyXX.rb --no-line-convert`.
4. Run the script `./tools/scripts/import_whitequark.sh`.

This will import all the relevant Whitequark tests for the targeted version under `test/whitequark`.

The PR [#3226](https://github.com/sorbet/sorbet/pull/3226) gives an example of the modifications to
apply on the script.

Once imported, Whitequark tests can be run with `bazel test --config=dbg //test:whitequark_parser_tests`.

Note: Some tests will need to be adapted to match the node names or output format used by Sorbet parser.

### Updating Sorbet lexer

Sorbet uses a [Ragel lexer](http://www.colm.net/open-source/ragel/) adapted from the
[Whitequark one](https://github.com/whitequark/parser/blob/master/lib/parser/lexer.rl).
Sorbet's Ragel specification file can be found under `sorbet/third_party/parser/cc/lexer.rl`.
You'll have to import and adapt the Ruby changes made on the Whitequark lexer to the C++ implementation
of the Sorbet one.

Note that while Sorbet only support one version of Ruby (the last one), we keep its lexer as close as
possible as the Whitequark one.
This means reproducing all the conditions based on the Ruby version such as:

```cpp
if (version >= ruby_version::RUBY_27) {
	// Lexer code for Ruby versions higher than RUBY27
} else {
	// Lexer code for Ruby versions lower than RUBY27
}
```

Keeping these versions switches makes it easier to compare Sorbet's lexer to the Whitequark one.

### Updating Sorbet parser

Like Whitequark, Sorbet uses a [Bison](https://en.wikipedia.org/wiki/GNU_Bison) grammar file to generate
its parser.

#### Incrementing Ruby version

Sorbet parser C++ code references the Ruby version currently supported in a few places.

These will need to be updated to change `typedrubyXX` to `typedrubyYY`:

* `parser/Parser.cc` (change `typedrubyXX`)
* `third_party/parser/cc/capi.cc` (change `typedrubyXX`, `rbdriver_typedrubyXX_new`, and
  `rbdriver_typedrubyXX_free`)
* `third_party/parser/cc/driver.cc` (change `typedrubyXX` and `RUBY_XX`)
* `third_party/parser/cc/grammars/typedruby.ypp` (change `typedrubyXX`)
* `third_party/parser/include/ruby_parser/capi.hh` (change `typedrubyXX`, `rbdriver_typedrubyXX_new`,
  and `rbdriver_typedrubyXX_free`)
* `third_party/parser/include/ruby_parser/lexer.hh` (add `RUBY_XX` constant for your version)

The PR [#3226](https://github.com/sorbet/sorbet/pull/3226) gives an example of the modifications to apply.

#### Updating the grammar

While Whitequark provides one grammar file per Ruby version, Sorbet tries to support as many versions
as possible in the same grammar file.
The grammar file is located under `third_party/parser/cc/grammars/typedruby.ypp`.

Contrary to Whitequark, productions are created by the `Builder` and not directly in the grammar file.
See `parser/Builder.cc` and `third_party/parser/include/ruby_parser/builder.hh`.
New nodes need to be defined in `parser/tools/generate_ast.cc`.

When introducing new nodes, don't forget to update `ast/desugar/Desugar.cc` accordingly.

The PR [#3258](https://github.com/sorbet/sorbet/pull/3258) gives an example of the small change
performed on the grammar. PR [#3313](https://github.com/sorbet/sorbet/pull/3313) shows how we added
support for Ruby's beginless ranges. PR [#3420](https://github.com/sorbet/sorbet/pull/3420) shows
another example for Ruby's forwarding argument support.
