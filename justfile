[group: 'build']
build:
    swift build

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