#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_sv_2pvbyte
#include "ppport.h"

#include "lz4.h"

#define BLOCK_MAGIC         0x4c5a3445 /* LZ4E (LZ4 Extended) */
#define BLOCK_MAGIC_SIZE    4
#define BLOCK_LENGTH_SIZE   4
#define HEADER_LENGTH       (BLOCK_MAGIC_SIZE + BLOCK_LENGTH_SIZE)

#if defined(_MSC_VER)    // Visual Studio
#define swap32 _byteswap_ulong
#elif GCC_VERSION >= 430
#define swap32 __builtin_bswap32
#else
static inline unsigned int
swap32(unsigned int x) {
    return  ((x << 24) & 0xff000000 ) |
            ((x <<  8) & 0x00ff0000 ) |
            ((x >>  8) & 0x0000ff00 ) |
            ((x >> 24) & 0x000000ff );
}
#endif

static const int one = 1;
#define CPU_LITTLE_ENDIAN  (*(char*)(&one))
#define CPU_BIG_ENDIAN     (!CPU_LITTLE_ENDIAN)
#define LITTLE_ENDIAN32(i) do {             \
    if (CPU_BIG_ENDIAN) { i = swap32(i); }  \
} while (0)

MODULE = Compress::LZ4    PACKAGE = Compress::LZ4

PROTOTYPES: ENABLE

SV *
compress (sv)
    SV *sv
PREINIT:
    char *src, *dest;
    STRLEN src_len, dest_len;
    unsigned magic = BLOCK_MAGIC, length;
    SV *retsv;
PPCODE:
    if (SvROK(sv)) sv = SvRV(sv);
    if (! SvOK(sv)) XSRETURN_NO;
    src = SvPVbyte(sv, src_len);
    if (! src_len) XSRETURN_NO;
    length = src_len;
    dest_len = HEADER_LENGTH + LZ4_compressBound(src_len);
    retsv = sv_2mortal(newSV(dest_len));
    dest = SvPVX(retsv);

    /* Add the length and magic header */
    LITTLE_ENDIAN32(magic);
    LITTLE_ENDIAN32(length);
    *(unsigned *)dest    = magic; dest += BLOCK_MAGIC_SIZE;
    *(unsigned *)dest   = length; dest += BLOCK_LENGTH_SIZE;

    dest_len = LZ4_compress(src, dest, src_len);
    SvCUR_set(retsv, HEADER_LENGTH + dest_len);
    SvPOK_only(retsv);
    XPUSHs(retsv);

SV *
decompress (sv)
    SV *sv
ALIAS:
    uncompress = 1
PREINIT:
    char *src, *dest;
    STRLEN src_len, dest_len;
    unsigned magic;
    int nread, tread = 0, total_len = 0;
    SV *retsv = NULL;
PPCODE:
    PERL_UNUSED_VAR(ix);  /* -W */
    if (SvROK(sv)) sv = SvRV(sv);
    if (! SvOK(sv)) XSRETURN_NO;

    src_len = SvCUR(sv);
    if (! src_len)
        XSRETURN_NO;
    src = SvPVX(sv);
    while (tread < src_len) {
        if (src_len <= HEADER_LENGTH)
            XSRETURN_NO;

        /* Decode the magic and length header. */
        magic    = ((unsigned *)src)[0];
        LITTLE_ENDIAN32(magic);

        if (magic != BLOCK_MAGIC) {
            magic = 0; /* decompress as a single block */
            dest_len = ((unsigned *)src)[0];
            LITTLE_ENDIAN32(dest_len);
            src += BLOCK_LENGTH_SIZE;
            src_len -= BLOCK_LENGTH_SIZE;
        } else {
            dest_len = ((unsigned *)src)[1];
            LITTLE_ENDIAN32(dest_len);
            src += HEADER_LENGTH;
            src_len -= HEADER_LENGTH;
        }
        if (retsv == NULL) {
            retsv = sv_2mortal(newSV(dest_len));
            dest = SvPVX(retsv);
        } else {
            dest = SvGROW(retsv, dest_len + total_len);
            dest += total_len;
        }
        if (0 > (nread = LZ4_uncompress(src, dest, dest_len)))
            XSRETURN_UNDEF;
        total_len += dest_len;
        if (magic == 0) break;
        src += nread; tread += nread;
    }
    SvCUR_set(retsv, total_len);
    SvPOK_on(retsv);
    XPUSHs(retsv);
