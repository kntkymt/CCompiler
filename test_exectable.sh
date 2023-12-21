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
assert 5 "int main(){int a;return a = 5;}"
assert 6 "int main(){int a;a = 5;return a + 1;}"
assert 2 "int main(){int a;int b;a=b=1;return a + b;}"
assert 6 "int main(){int a;a = 5;int b;b = 1;return a + b;}"
assert 14 "int main(){int a;a = 3;int b;b = 5 * 6 - 8;return a + b / 2;}"
assert 15 "int main(){int hoge;hoge = 5;int fuga;fuga = 3;return hoge * fuga;}"
assert 1 "int main(){return 1; return 0;}"
assert 12 "int main(){int a;a = 0;while (a < 10) a=a+3;return a;}"
assert 10 "int main(){int a;a=0;if (1) a=10; return a;}"
assert 0 "int main(){int a;a=0;if (0) a=10; return a;}"
assert 20 "int main(){int a;a=0;if (0) a=10; else a=20; return a;}"
assert 30 "int main(){int a;a=0;if (0) a=10; else if (0) a=20; else a=30; return a;}"
assert 30 "int main(){int a;int i;a=0;for(i=0;i<10;i=i+1)a=a+3;return a;}"
assert 15 "int main(){int a;int i;a=0;i=5;for(;i<10;i=i+1)a=a+3;return a;}"
assert 12 "int main(){int a;a=0;for(;a<10;)a=a+3;return a;}"
assert 10 "int main(){int a;a=0;for(;;a=a+1)if(a>=10)return a;}"
assert 20 "int main(){int a;a=1;if (1) { a=a+1; a=a*10; } return a;}"
assert 30 "int main(){int a;int b;int i;a=0;b=0;for(i=0;i<10;i=i+1) { a=a+3; b=a; } return b;}"
assert 12 "int main(){int a;a = 0;while (a < 10) { a=a+3; } return a;}"
assert 5 "int sub() { return 5; } int main() { return sub(); }"
assert 6 "int sub() { return 5; } int main() { int a; a=1; int b; b = sub(); return a + b; }"
assert 3 "int sum(int a, int b) { return a + b; } int main() { return sum(1, 2); }"
assert 12 "int sum(int a, int b) { return a * 10 + b; } int main() { return sum(1, 2); }"
assert 74 "int sum(int a, int b, int c) { int d; d = 10; return a * 2 + b * 3 + c * 4 + d * 5; } int main() { int a; a = 1; return sum(a * 3, 2, 3); }"
assert 5 "int main() { int a; int b; a = 5; b = &a; return *b; }"
assert 5 "int main() { int a; a = 5; return *&a; }"
assert 5 "int sub() { int a; a = 5; return a; } int main() { int a; a = 10; return sub(); }"
assert 10 "int main() { int a; int* b; a = 5; b = &a; *b = 10; return a; }"
assert 20 "int main() { int a; int* b; int** c; a = 5; b = &a; c = &b; **c = 20; return a; }"
assert 30 "int main() { int a; int d; int* b; int** c; a = 5; d = 10; b = &a; c = &b; *c = &d; **c = 30; return d; }"
assert 5 "int main() { int a; int b; int* c; a = 5; b = 10; c = &b; c = c + 1; return *c; }"
assert 10 "int main() { int a; int b; int* c; a = 5; b = 10; c = &a; c = c - 1; return *c; }"
assert 15 "int main() { int a; int b; int* c; a = 5; b = 10; c = &b; c = c + 1; *c = 15; return a; }"
assert 8 "int main() { return sizeof(1); }"
assert 8 "int main() { int a; a = 10; return sizeof(a); }"
assert 8 "int main() { int a; a = 10; return sizeof(a + 1); }"
assert 80 "int main() { int a; int b[10]; return &a - &b; }"
assert 1 "int main() { int a[2]; *a = 1; return *a; }"
assert 2 "int main() { int a[2]; *(a + 1) = 2; return *(a + 1); }"
assert 1 "int main() { int a[2]; int *p; p = a; return a == p; }"
assert 5 "int main() { int a[2]; int *p; p = a; *(p + 1) = 5; return *(a + 1); }"
assert 3 "int main() { int a[2]; *a = 1; *(a + 1) = 2; int *p; p = a; return *p + *(p + 1); }"
assert 5 "int main() { int a[2]; a[0] = 5; return a[0]; }"
assert 8 "int main() { int a; int* b; a = b + 1; int c; c = b; return a - c; }"
assert 17 "int main() { int a[3]; int b; b = 1; a[b] = 7; a[b+1] = 10; return a[b] + a[b+1]; }"
assert 5 "int main() { int a[2]; a[1] = 5; int* p; p = a; return p[1]; }"
assert 5 "int main() { int a[2]; a[1] = 5; return *(a+1); }"
assert 1 "int main() { int a[2]; a[1] = 5; int* p; p = a; return p[1] == *(p+1); }"
assert 10 "int g; int main() { g = 10; return g; }"
assert 100 "int g; int main() { g = 10; return g * 10; }"
assert 30 "int g; int sub() { g = 30; return 0; } int main() { g = 20; sub(); return g; }"
assert 30 "int g[10]; int main() { g[2] = 10; g[3] = 20; return g[2] + g[2 + 1]; }"
assert 10 "int main() { char x; x = 10; return x; }"
assert 30 "int main() { char x; x = 10; char* p; p = &x; *p = 30; return x; }"
assert 3 "int main() { char x[3]; x[0] = -1; x[1] = 2; int y; y = 4; return x[0] + y; }"
assert 15 "char x; int main() { x = 15; return x; }"
assert 3 "char x[3]; int main() {  x[0] = -1; x[1] = 2; int y; y = 4; return x[0] + y; }"
assert 150 "int main() { int x; x = 300; return x / 2; }"
assert 22 "int main() { char x; x = 300; return x / 2; }"

echo OK
