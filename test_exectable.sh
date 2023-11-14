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

assert 0 "return 0;"
assert 42 "return 42;"
assert 21 "return 5+20-4;"
assert 200 "return 100+2-2+100;"
assert 41 " return 12 + 34 - 5 ;"
assert 47 "return 5+6*7;"
assert 15 "return 5*(9-6);"
assert 4 "return (3+5)/2;"
assert 10 "return -20 + 30;"
assert 1 "return 1 < 2;"
assert 1 "return 2 <= 3;"
assert 1 "return 3 > -4;"
assert 1 "return 10 >= 1;"
assert 1 "return -1 != 1;"
assert 1 "return 0 == 0;"
assert 5 "return a = 5;"
assert 6 "a = 5;return a + 1;"
assert 6 "a = 5;b = 1;return a + b;"
assert 2 "a=b=1;return a + b;"
assert 14 "a = 3;b = 5 * 6 - 8;return a + b / 2;"
assert 15 "hoge = 5;fuga = 3;return hoge * fuga;"
assert 1 "return 1; return 0;"
assert 12 "a = 0;while (a < 10) a=a+3;return a;"
assert 10 "a=0;if (1) a=10; return a;"
assert 0 "a=0;if (0) a=10; return a;"
assert 20 "a=0;if (0) a=10; else a=20; return a;"
assert 30 "a=0;if (0) a=10; else if (0) a=20; else a=30; return a;"
assert 30 "a=0;for(i=0;i<10;i=i+1)a=a+3;return a;"
assert 15 "a=0;i=5;for(;i<10;i=i+1)a=a+3;return a;"
assert 12 "a=0;for(;a<10;)a=a+3;return a;"
assert 10 "a=0;for(;;a=a+1)if(a>=10)return a;"

echo OK
