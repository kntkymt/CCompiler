#!/bin/bash
assert() {
  expected="$1"
  input="$2"

  ./.build/release/ccompiler "./ExecutableTests/$input" -o output.s
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

assert 0 "000.c"
assert 42 "001.c"
assert 21 "002.c"
assert 200 "003.c"
assert 41 "004.c"
assert 47 "005.c"
assert 15 "006.c"
assert 4 "007.c"
assert 10 "008.c"
assert 1 "009.c"
assert 1 "010.c"
assert 1 "011.c"
assert 1 "012.c"
assert 1 "013.c"
assert 1 "014.c"
assert 5 "015.c"
assert 6 "016.c"
assert 2 "017.c"
assert 6 "018.c"
assert 14 "019.c"
assert 15 "020.c"
assert 1 "021.c"
assert 12 "022.c"
assert 10 "023.c"
assert 0 "024.c"
assert 20 "025.c"
assert 30 "026.c"
assert 30 "027.c"
assert 15 "028.c"
assert 12 "029.c"
assert 10 "030.c"
assert 20 "031.c"
assert 30 "032.c"
assert 12 "033.c"
assert 5 "034.c"
assert 6 "035.c"
assert 3 "036.c"
assert 12 "037.c"
assert 74 "038.c"
assert 5 "039.c"
assert 5 "040.c"
assert 5 "041.c"
assert 10 "042.c"
assert 20 "043.c"
assert 30 "044.c"
assert 5 "045.c"
assert 10 "046.c"
assert 15 "047.c"
assert 8 "048.c"
assert 8 "049.c"
assert 8 "050.c"
assert 80 "051.c"
assert 1 "052.c"
assert 2 "053.c"
assert 1 "054.c"
assert 5 "055.c"
assert 3 "056.c"
assert 5 "057.c"
assert 8 "058.c"
assert 17 "059.c"
assert 5 "060.c"
assert 5 "061.c"
assert 1 "062.c"
assert 10 "063.c"
assert 100 "064.c"
assert 30 "065.c"
assert 30 "066.c"
assert 10 "067.c"
assert 30 "068.c"
assert 3 "069.c"
assert 15 "070.c"
assert 3 "071.c"
assert 150 "072.c"
assert 22 "073.c"
assert 97 "074.c"
assert 0 "075.c"
assert 101 "076.c"
assert 104 "077.c"
assert 10 "078.c"
assert 20 "079.c"
assert 1 "080.c"

echo OK
