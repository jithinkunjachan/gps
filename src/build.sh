
# Compile for x86_64 architecture and place the binary file in the android/src/main/jniLibs/x86_64 folder
CGO_ENABLED=1  GOOS=android GOARCH=amd64 CC=/opt/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang \
go build -buildmode=c-shared -o ../android/src/main/jniLibs/x86_64/libsum.so .


CGO_ENABLED=1  GOOS=android GOARCH=arm64 CC=/opt/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
go build -buildmode=c-shared -o ../android/src/main/jniLibs/arm64-v8a/libsum.so .

# Compile for arm64 architecture and place the binary file in the android/src/main/jniLibs/arm64-v8a folder
#CGO_ENABLED=1 \
#GOOS=android \
#GOARCH=arm64 \
#CC=/opt/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/aarch64-linux-android21-clang \
#go build -buildmode=c-shared -o ../android/src/main/jniLibs/arm64-v8a/libsum.so .