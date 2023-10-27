test:
	clang -o output CCompilerDemo/CCompilerDemo/Output/out.s
	./output
	echo $?
