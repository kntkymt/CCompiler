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

assert 0 "int main(){return 0;}"
assert 42 "int main(){return 42;}"
assert 21 "int main(){return 5+20-4;}"
assert 200 "int main(){return 100+2-2+100;}"
assert 41 "int   main(  )  { return 12 + 34 - 5 ;   }"
assert 47 "int main(){return 5+6*7;}"
assert 15 "int main(){return 5*(9-6);}"
assert 4 "int main(){return (3+5)/2;}"
assert 10 "int main(){return -20 + 30;}"
assert 1 "int main(){return 1 < 2;}"
assert 1 "int main(){return 2 <= 3;}"
assert 1 "int main(){return 3 > -4;}"
assert 1 "int main(){return 10 >= 1;}"
assert 1 "int main(){return -1 != 1;}"
assert 1 "int main(){return 0 == 0;}"
assert 5 "int main(){return a = 5;}"
assert 6 "int main(){a = 5;return a + 1;}"
assert 2 "int main(){a=b=1;return a + b;}"
assert 6 "int main(){a = 5;b = 1;return a + b;}"
assert 14 "int main(){a = 3;b = 5 * 6 - 8;return a + b / 2;}"
assert 15 "int main(){hoge = 5;fuga = 3;return hoge * fuga;}"
assert 1 "int main(){return 1; return 0;}"
assert 12 "int main(){a = 0;while (a < 10) a=a+3;return a;}"
assert 10 "int main(){a=0;if (1) a=10; return a;}"
assert 0 "int main(){a=0;if (0) a=10; return a;}"
assert 20 "int main(){a=0;if (0) a=10; else a=20; return a;}"
assert 30 "int main(){a=0;if (0) a=10; else if (0) a=20; else a=30; return a;}"
assert 30 "int main(){a=0;for(i=0;i<10;i=i+1)a=a+3;return a;}"
assert 15 "int main(){a=0;i=5;for(;i<10;i=i+1)a=a+3;return a;}"
assert 12 "int main(){a=0;for(;a<10;)a=a+3;return a;}"
assert 10 "int main(){a=0;for(;;a=a+1)if(a>=10)return a;}"
assert 20 "int main(){a=1;if (1) { a=a+1; a=a*10; } return a;}"
assert 30 "int main(){a=0;b=0;for(i=0;i<10;i=i+1) { a=a+3; b=a; } return b;}"
assert 12 "int main(){a = 0;while (a < 10) { a=a+3; } return a;}"
assert 5 "int sub() { return 5; } int main() { return sub(); }"
assert 6 "int sub() { return 5; } int main() { a=1; b = sub(); return a + b; }"
assert 3 "int sum(int a, int b) { return a + b; } int main() { return sum(1, 2); }"
assert 12 "int sum(int a, int b) { return a * 10 + b; } int main() { return sum(1, 2); }"
assert 74 "int sum(int a, int b, int c) { d = 10; return a * 2 + b * 3 + c * 4 + d * 5; } int main() { a = 1; return sum(a * 3, 2, 3); }"
assert 5 "int main() { a = 5; b = &a; return *b; }"
assert 5 "int main() { a = 5; return *&a; }"

echo OK
