# drrecorder
Wrapper around youtube-dl to schedule recording live transmissions from Danmarks Radio

To build and install locally:
```
$ swift build -c release -Xswiftc -static-stdlib
$ cd .build/release
$ cp -f DRRecorder /usr/local/bin/drrecorder
```
