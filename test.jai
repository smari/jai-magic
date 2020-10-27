#load "module.jai";
#import "Basic";
#import "File";

main :: () {
    ms: magic_t;
	result: string;
	desired_len: size_t;
	i : int;
	fp: File;
    success :bool;

    ms = magic_open(MAGIC_NONE);
    if (ms == null) {
		print("ERROR opening MAGIC_NONE: out of memory\n");
		return;
	}

	if (magic_load(ms, null) == -1) {
		print("ERROR loading with NULL file: %\n", magic_error(ms));
		return;
	}

    args := get_command_line_arguments();
    defer array_reset(*args);

	if (args.count != 2) {
		print("Usage: test TEST-FILE\n");
	} else {
        result = magic_file(ms, args[1]);
		if !result {
			print("ERROR loading file %: %\n", args[1], magic_error(ms));
			return;
		}
		print("%: %\n", args[1], result);
	}

	magic_close(ms);
}
