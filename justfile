[group: 'build']
build:
    swift build

[group: 'build']
debug-build:
    swift build -Xswiftc -dump-macro-expansions

# [group: 'build']
# build-release:
#     swift build --configuration release

[group: 'test']
run: build
    swift run SwiftHDLExamples

[group: 'clean']
clean:
    swift package clean
    rm -rf .build
