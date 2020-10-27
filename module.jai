
MAGIC_NONE :: 0x000000; // No flags
MAGIC_DEBUG :: 0x000001; // Turn on debugging
MAGIC_SYMLINK :: 0x000002; // Follow symlinks
MAGIC_COMPRESS :: 0x000004; // Check inside compressed files
MAGIC_DEVICES :: 0x000008; // Look at the contents of devices
MAGIC_MIME_TYPE :: 0x000010; // Return the MIME type
MAGIC_CONTINUE :: 0x000020; // Return all matches
MAGIC_CHECK :: 0x000040; // Print warnings to stderr
MAGIC_PRESERVE_ATIME :: 0x000080; // Restore access time on exit
MAGIC_RAW :: 0x000100; // Don't translate unprintable chars
MAGIC_ERROR :: 0x000200; // Handle ENOENT etc as real errors
MAGIC_MIME_ENCODING :: 0x000400; // Return the MIME encoding
MAGIC_MIME :: (MAGIC_MIME_TYPE|MAGIC_MIME_ENCODING);
MAGIC_APPLE :: 0x000800; // Return the Apple creator and type

MAGIC_NO_CHECK_COMPRESS :: 0x001000; // Don't check for compressed files
MAGIC_NO_CHECK_TAR :: 0x002000; // Don't check for tar files
MAGIC_NO_CHECK_SOFT :: 0x004000; // Don't check magic entries
MAGIC_NO_CHECK_APPTYPE :: 0x008000; // Don't check application type
MAGIC_NO_CHECK_ELF :: 0x010000; // Don't check for elf details
MAGIC_NO_CHECK_TEXT :: 0x020000; // Don't check for text files
MAGIC_NO_CHECK_CDF :: 0x040000; // Don't check for cdf files
MAGIC_NO_CHECK_TOKENS :: 0x100000; // Don't check tokens
MAGIC_NO_CHECK_ENCODING :: 0x200000; // Don't check text encodings

/* No built-in tests; only consult the magic file */
MAGIC_NO_CHECK_BUILTIN :: (
	MAGIC_NO_CHECK_COMPRESS	|
	MAGIC_NO_CHECK_TAR	|
/*	MAGIC_NO_CHECK_SOFT	| */
	MAGIC_NO_CHECK_APPTYPE	|
	MAGIC_NO_CHECK_ELF	|
	MAGIC_NO_CHECK_TEXT	|
	MAGIC_NO_CHECK_CDF	|
	MAGIC_NO_CHECK_TOKENS	|
	MAGIC_NO_CHECK_ENCODING	|
	0
);

/* Defined for backwards compatibility; do nothing */
MAGIC_NO_CHECK_FORTRAN :: 0x000000; // Don't check ascii/fortran
MAGIC_NO_CHECK_TROFF :: 0x000000; // Don't check ascii/troff

MAGIC_VERSION :: 517; // This implementation

magic_t :: *magic_set;

magic_open :: (flags: s32 = MAGIC_NONE) -> magic_t          #foreign magic;
magic_close :: (cookie: magic_t)                            #foreign magic;
magic_error :: (cookie: magic_t) -> *u8                     #foreign magic;
magic_errno :: (cookie: magic_t) -> u32                     #foreign magic;
magic_file :: (cookie: magic_t, filename: *u8) -> *u8       #foreign magic;
magic_buffer :: (cookie: magic_t, buffer: *void, length: size_t) -> *u8 #foreign magic;
magic_setflags :: (cookie: magic_t, flags: s32) -> s32      #foreign magic;
magic_check :: (cookie: magic_t, filename: *u8) -> s32      #foreign magic;
magic_compile :: (cookie: magic_t, filename: *u8) -> s32     #foreign magic;
magic_load :: (cookie: magic_t, filename: *u8) -> s32        #foreign magic;

magic_file :: (cookie: magic_t, filename: string) -> string {
    return to_string(magic_file(cookie, to_c_string(filename)));
}

magic_string :: (cookie: magic_t, buffer: string) -> string {
    return to_string(magic_buffer(cookie, buffer.data, xx buffer.count));
}

#scope_file
#import "POSIX";
magic :: #foreign_system_library "libmagic";

MAGIC_SETS :: 2;

INDIR       :: 0x01;
OFFADD      :: 0x02;
INDIROFFADD :: 0x04;
UNSIGNED    :: 0x08;
NOSPACE     :: 0x10;
BINTEST     :: 0x20;
TEXTTEST    :: 0x40;

MAXDESC     :: 64;
MAXMIME     :: 80;
MAXstring   :: 96;

magic_ent :: struct {
    cont_level:     u16;
    flag:           u8;
    factor:         u8;

    reln:           u8;
    vallen:         u8;
    type:           u8;
    in_type:        u8;

    in_op:          u8;
    mask_op:        u8;
    cond:           u8;
    factor_op:      u8;

    offset:         s32;
    in_offset:      s32;
    lineno:         u32;
    _u:             u64;

    value:          [MAXstring]u8;
    desc:           [MAXDESC]u8;
    mimetime:       [MAXMIME]u8;
    apple:          [8]u8;
    ext:            [64]u8;
}

level_info :: struct {
        off : s32;
        got_match: s32;
        last_match: s32;
        last_cond: s32;  /* used for error checking by parse() */
};

mlist_t :: struct {
        magic: *magic_ent;            /* array of magic entries */
        nmagic: u32;                /* number of entries in array */
        map: *void;                      /* internal resources used by entry */
        next: *mlist_t;
        prev: *mlist_t;
};

magic_set :: struct {
        mlist :: *[MAGIC_SETS] mlist_t;        /* list of regular entries */
        cont :: struct {
                len : size_t;
                li: *level_info;
        };
        c : cont;
        out :: struct {
                buf: *u8;              /* Accumulation buffer */
                pbuf: *u8;             /* Printable buffer */
        };
        o : out;
        offset : u32;                /* a copy of m->offset while we */
                                        /* are working on the magic entry */
        eoffset : u32;               /* offset from end of file */
        error : s32;
        flags : s32;                      /* Control magic tests. */
        event_flags : s32;                /* Note things that happened. */

        file : *u8;
        line : size_t;                  /* current magic line number */
        mode : mode_t;                    /* copy of current stat mode */

        /* data for searches */
        search :: struct {
                s: *u8;          /* start of search in original source */
                s_len: size_t;           /* length of search region */
                offset: size_t;          /* starting offset in source */
                rm_len: size_t;          /* match length */
        };

        s : search;

        /* FIXME: Make the string dynamically allocated so that e.g.
           strings matched in files can be longer than MAXstring */
        ms_value : [MAXstring]u8;       /* either number or string */
        indir_max : u16;
        name_max : u16;
        elf_shnum_max : u16;
        elf_phnum_max : u16;
        elf_notes_max : u16;
        regex_max : u16;
        bytes_max : size_t;               /* number of bytes to read from file */
};

FILE_INDIR_MAX :: 50;
FILE_NAME_MAX :: 30;
FILE_ELF_SHNUM_MAX :: 32768;
FILE_ELF_PHNUM_MAX :: 2048;
FILE_ELF_NOTES_MAX :: 256;
FILE_REGEX_MAX :: 8192;
EVENT_HAD_ERR :: 0;
