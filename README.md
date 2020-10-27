# libmagic wrapper for Jai

Basic wrapper for libmagic. Enjoy.

## Example
```
#import "Magic"

main :: () {
    mg := magic_open();
    s := magic_file(mg, "/bin/bash");
    print("Magic: %", s);
}
```
