build:
	swift build -c release

test_modules:
	swift test

test_exectable: build
	./test_exectable.sh
