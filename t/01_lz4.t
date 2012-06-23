use strict;
use warnings;
use Test::More;
use Compress::LZ4;

for (qw(compress decompress uncompress)) {
    ok eval "defined &$_", "$_() is exported";
}

{
    no warnings 'uninitialized';
    my $compressed = compress(undef);
    my $decompressed = decompress($compressed);
    is $decompressed, '', 'undef';
}

for my $len (0 .. 1_024) {
    my $in = '0' x $len;
    my $compressed = compress($in);
    my $decompressed = decompress($compressed);
    is $decompressed, $in, "length: $len";
}

my $scalar = '0' x 1_024;
ok compress($scalar) eq compress(\$scalar), 'scalar ref';

# https://rt.cpan.org/Public/Bug/Display.html?id=75624
{
    # Remove the length header.
    my $data = unpack "x8 a*", compress('0' x 14);
    ok $data eq "\0240\001\0P00000", 'AMD64 bug';
}

sub chargen {
    my $str = '';
    my $n = 0x21222324;
    for (0..22) {
        $str .= pack(N => $n);
        $n += 0x4040404;
    }; $str . '}~';
}

{ # decompress multiple blocks
    my $expected = chargen();
    my $compressed = compress($expected) . compress($expected);
    my $decompressed = decompress($compressed);
    ok $expected . $expected eq $decompressed , 'decompress multiple blocks';
}

{ # decompress without magic
    my $expected = chargen();
    my $compressed = compress($expected);
    substr $compressed, 0, 4, ''; # chop off magic
    my $decompressed = decompress($compressed);
    ok $expected eq $decompressed, 'decompress old';
}

done_testing;
