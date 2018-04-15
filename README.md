# drrecorder
Wrapper around youtube-dl to schedule recording live transmissions from Danmarks Radio

To build and install locally:
```
$ swift build -c release -Xswiftc -static-stdlib
$ cd .build/release
$ cp -f drrecorder /usr/local/bin/drrecorder
```

To run from source:
```
swift run drrecorder --channel DR-K --start '2018-04-15 17:50' --end '2018-04-15 18:50' --name 'Matador 19'
```

Example usage when installed:
```
drrecorder --channel DR-K --start '2018-04-15 17:50' --end '2018-04-15 18:50' --name 'Matador 19'
```

This will start the recording from DR-K at 17:50 and stop it at 18:50 and name the recording "Matador 19.mp4"

To install the required dependency "youtube-dl":

```
brew install youtube-dl
```

or go to https://youtube-dl.org and follow the docs.

To install Homebrew:
Go to https://brew.sh and follow the docs.
