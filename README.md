# piper-wasm

WASM version of [espeak-ng](https://github.com/espeak-ng/espeak-ng) for phonemizing.

## Version

Using branch 1.52.0 instead of master (2025-12-10), as the tag version provides different phonemes:

- 1.52.0: `mˈiːdiːə mˈanɪd‍ʒə`
- master: `mˈiːdiːʲə mˈanɪd‍ʒə`

These from 1.52.0 sounds better when used with kokoro.

## Build WASM

```sh
# Docker (optional)
docker run -it -v $(pwd):/wasm -w /wasm debian:12.5
./build.sh
```

Produces `espeakng.js` and `espeakng.wasm` in root.

## Docker Reattach

Reattach stdin for exited container:

```shell
docker ps -q -l              # find container ID (or discover via Docker desktop)
docker start 3df55acbb7c4    # restart in the background
docker attach 3df55acbb7c4   # reattach the terminal & stdin
```