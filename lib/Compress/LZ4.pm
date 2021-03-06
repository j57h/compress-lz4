package Compress::LZ4;

use strict;
use warnings;
use parent qw(Exporter);

use XSLoader;

our $VERSION    = '0.13';
our $XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

XSLoader::load(__PACKAGE__, $XS_VERSION);

our @EXPORT = qw(compress decompress uncompress);


1;

__END__

=head1 NAME

Compress::LZ4 - Perl interface to the LZ4 (de)compressor

=head1 SYNOPSIS

    use Compress::LZ4;

    my $dest = compress($source);
    my $dest = decompress($source);

=head1 DESCRIPTION

The C<Compress::LZ4> module provides an interface to the LZ4 (de)compressor.

=head1 FUNCTIONS

=head2 compress

    $string = compress($buffer)

Compresses the given buffer and returns the resulting string. The input
buffer can be either a scalar or a scalar reference.

=head2 decompress

=head2 uncompress

    $string = decompress($buffer)

Decompresses the given buffer and returns the resulting string. The input
buffer can be either a scalar or a scalar reference.

On error (in case of corrupted data) undef is returned.

=head1 PERFORMANCE

This distribution contains a benchmarking script which compares serveral
compression modules available on CPAN.  These are the results on a MacBook
2GHz Core 2 Duo (64-bit) with Perl 5.14.2:

    Compressible data (10 KiB) - compression
    ----------------------------------------
    Compress::LZ4::compress     183794/s  1795 MiB/s  1.152%
    Compress::Snappy::compress  122496/s  1196 MiB/s  5.332%
    Compress::LZF::compress      44383/s   433 MiB/s  1.865%
    Compress::Zlib::compress      2765/s    27 MiB/s  1.201%
    Compress::Bzip2::compress      110/s     1 MiB/s  2.070%

    Compressible data (10 KiB) - decompression
    ------------------------------------------
    Compress::LZ4::decompress     546133/s  5333 MiB/s
    Compress::Snappy::decompress  175363/s  1713 MiB/s
    Compress::LZF::decompress     135244/s  1321 MiB/s
    Compress::Bzip2::decompress     6352/s    62 MiB/s
    Compress::Zlib::uncompress      5440/s    53 MiB/s

    Uncompressible data (10 KiB) - compression
    ------------------------------------------
    Compress::LZ4::compress     763738/s  7458 MiB/s  107.463%
    Compress::Snappy::compress  552269/s  5393 MiB/s  100.000%
    Compress::LZF::compress     532919/s  5204 MiB/s  101.493%
    Compress::Bzip2::compress    15424/s   151 MiB/s  185.075%
    Compress::Zlib::compress      4325/s    42 MiB/s  105.970%

    Uncompressible data (10 KiB) - decompression
    --------------------------------------------
    Compress::LZF::decompress     2583577/s  25230 MiB/s
    Compress::LZ4::decompress     2383127/s  23273 MiB/s
    Compress::Snappy::decompress  2068002/s  20195 MiB/s
    Compress::Bzip2::decompress     48650/s    475 MiB/s
    Compress::Zlib::uncompress       6342/s     62 MiB/s

=head1 SEE ALSO

L<http://code.google.com/p/lz4/>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Compress-LZ4>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Compress::LZ4

You can also look for information at:

=over

=item * GitHub Source Repository

L<https://github.com/gray/compress-lz4>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Compress-LZ4>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Compress-LZ4>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/Public/Dist/Display.html?Name=Compress-LZ4>

=item * Search CPAN

L<http://search.cpan.org/dist/Compress-LZ4/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut
