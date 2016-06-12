# Formatting
* Tabs
* No spaces between function arguments and closures
  * `foo(bar)`, not `foo( bar )`
* Functions intended to be used from other files should be CamelCase and functions intended for local use should be mixedCase.
  * Local functions (as in `local function foo()`) will not work unless in functions or in `ios.lua`