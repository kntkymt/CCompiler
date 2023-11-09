#!/bin/bash
assert() {
  expected="$1"
  input="$2"

  ./.build/release/ccompiler "$input"
  clang -o output output.s
  ./output
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input => $actual"
  else
    echo "$input => $expected expected, but got $actual"
    exit 1
  fi
}

assert 0 "0;"
assert 42 "42;"
assert 21 "5+20-4;"
assert 200 "100+2-2+100;"
assert 41 " 12 + 34 - 5 ;"
assert 47 "5+6*7;"
assert 15 "5*(9-6);"
assert 4 "(3+5)/2;"
assert 10 "-20 + 30;"
assert 1 "1 < 2;"
assert 1 "2 <= 3;"
assert 1 "3 > -4;"
assert 1 "10 >= 1;"
assert 1 "-1 != 1;"
assert 1 "0 == 0;"
assert 5 "a = 5;"
assert 6 "a = 5;a + 1;"
assert 6 "a = 5;b = 1;a + b;"
assert 2 "a=b=1;a + b;"
assert 14 "a = 3;b = 5 * 6 - 8;a + b / 2;"
assert 15 "hoge = 5;fuga = 3;hoge * fuga;"

echo OK
