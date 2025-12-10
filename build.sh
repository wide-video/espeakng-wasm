#!/bin/bash

apt-get update
apt-get install --yes --no-install-recommends build-essential cmake ca-certificates curl pkg-config git python3 autogen automake autoconf libtool

# Emscripten
git clone --depth 1 https://github.com/emscripten-core/emsdk.git /wasm/modules/emsdk
cd /wasm/modules/emsdk
./emsdk install 4.0.21
./emsdk activate 4.0.21
source ./emsdk_env.sh
TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
sed -i -E 's/int\s+(iswalnum|iswalpha|iswblank|iswcntrl|iswgraph|iswlower|iswprint|iswpunct|iswspace|iswupper|iswxdigit)\(wint_t\)/\/\/\0/g' ./upstream/emscripten/cache/sysroot/include/wchar.h

# espeak-ng
# https://github.com/ianmarmour/espeak-ng.js
git clone --branch 1.52.0 --depth 1 https://github.com/espeak-ng/espeak-ng.git /wasm/modules/espeak-ng
cd /wasm/modules/espeak-ng
./autogen.sh
./configure --without-async --without-mbrola --without-sonic --without-pcaudiolib --without-klatt --without-speechplayer --with-extdict-cmn
make

cd /wasm/modules/espeak-ng/src/ucd-tools
mv CHANGELOG.md CHANGELOG.tmp
mv CHANGELOG.tmp ChangeLog.md
./autogen.sh
./configure
make clean
emconfigure ./configure
emmake make clean
emmake make

# Remove unused (by kokoro) big dictionaries
rm /wasm/modules/espeak-ng/espeak-ng-data/ru_dict
rm /wasm/modules/espeak-ng/espeak-ng-data/fo_dict

cd /wasm/modules/espeak-ng
emconfigure ./configure --without-async --without-mbrola --without-sonic --without-pcaudiolib --without-klatt --without-speechplayer --with-extdict-cmn
emmake make clean
emmake make src/espeak-ng
emcc -O3 -s INVOKE_RUN=0 -s EXIT_RUNTIME=0 -s MODULARIZE=1 -s EXPORT_NAME='createESpeakNg' -s EXPORTED_FUNCTIONS='[_free, _malloc, _espeak_Initialize, _espeak_TextToPhonemes, _espeak_SetVoiceByName, _espeak_ListVoices]' -s EXPORTED_RUNTIME_METHODS='[lengthBytesUTF8, stringToUTF8, UTF8ToString, setValue, getValue, FS]' -s INITIAL_MEMORY=64MB -s STACK_SIZE=5MB -s DEFAULT_PTHREAD_STACK_SIZE=2MB src/.libs/libespeak-ng.so src/espeak-ng.o -o /wasm/espeakng.js --embed-file espeak-ng-data@/usr/local/share/espeak-ng-data/