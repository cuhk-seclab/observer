# Observer

Observer is a system for studying JavaScript click interception practices. It tracks the creation of HTML anchor and script elements, records accesses to HTML anchor elements, and monitors JavaScript event listeners.

Observer is implemented on Chromium (version 64.0.3282.186).

You can find more information about Observer in our [USENIX Security 2019 research paper](https://seclab.cse.cuhk.edu.hk/papers/sec19_click_interception.pdf). Please consider citing our paper when using Observer. The BibTeX format file is provided with the source code.

## Setup and Build
The following build script works only on Debian, Ubuntu and macOS.

```shell
# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:/path/to/depot_tools

# Fetch source and build
./build_observer.sh --all
```

The above command will fetch the source code of Chromium version 64.0.3282.186, apply our patch to it, and build Observer.

For more information about the options, use:

```shell
./build_observer.sh --help
```

When building on macOS, you might need to install an older version of MacOS SDK included by Xcode. The SDKs are available [here](https://github.com/phracker/MacOSX-SDKs).

You can also use distributed build tools like [icecc](https://github.com/icecc/icecream) to speedup the build.

## Run on Linux

```shell
cd src
ENABLE_OBSERVER=1 out/Observer/chrome --no-sandbox
```

## Run on macOS

```shell
cd src
ENABLE_OBSERVER=1 out/Observer/Chromium.app/Contents/MacOS/Chromium --no-sandbox
```

## Data Collection

For performance concerns, Observer adopts a lazy update mechanism for setting some custom attributes (e.g., initiator, observerLog, etc.). The values of these attributes are updated in the DOM tree only when the attributes are first accessed by JavaScript.
Following are the description about the attributes that are set and collected by Observer.

* The *observerLog* attribute includes logs of read & write operations by JavaScript.
* The *initiator* attribute represents the scriptID of the initiating script of an element.
* The *nid* attribute is a unique ID of a DOM node.
* The *displayInfo* attribute collects display related style properties of an element for detecting elements used in visual deception.
* The *scriptID* and *parentScriptID* attributes are the IDs of a script and its parent script.
* The *scriptIDMap* includes a map from the scriptID of a script to its URL in the document, and a map from the scriptID of a script to that of its parent script.
* The *apiLog* includes logs related to navigation events (e.g., nid, the navigation API name, the navigation URL, etc.) of an element.

We provide the following scripts to access the custom attributes. They can be injected to Chromium using Selenium after a page is completed loaded.

* *js/fetchDocLog.js*: traverse the DOM tree, access observerLog and initiator, etc., set displayInfo attribute of every HTML element and get the scriptID map.
* *js/fireEvents.js*: traverse the DOM tree, click all the clickable HTML element and retrieve the apiLog.

## Copyright Information
Copyright © 2019 The Chinese University of Hong Kong

### Additional Notes

Notice that some files in Observer may carry their own copyright notices.
In particular, Observer's code release contains modifications to source files from the Google Chromium project (https://www.chromium.org), which are distributed under their own original license.

## License

Observer is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

Copyright (c) 2019 The Chinese University of Hong Kong

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Developers

[Wei Meng](https://www.cse.cuhk.edu.hk/~wei/) <wei@cse.cuhk.edu.hk>

Mingxue Zhang <mxzhang@cse.cuhk.edu.hk>

## Contact ##

[Wei Meng](https://www.cse.cuhk.edu.hk/~wei/) <wei@cse.cuhk.edu.hk>
