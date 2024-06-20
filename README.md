# defaultb

A macOS CLI in Swift to configure the default browser.

## Installation

Compile the project with `make` and copy the binary to wherever you want.

Xcode is not required to compile the project, but Xcode command line tools may need to be installed.

## Usage

```
> defaultb -h 
Usage: defaultb [-l|-s <bundle_id>|-g|-h]

Options:
    -h, --help                   Print this help message
    -l, --list                   List the available browsers
    -s, --set <bundle_id>        Set the default browser to the given bundle ID
    -g, --get                    Get the default browser
```
