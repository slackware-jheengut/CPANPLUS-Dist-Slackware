package CPANPLUS::Dist::Slackware::Plugin::YAML::LibYAML;

use strict;
use warnings;

use File::Spec qw();

our $VERSION = '0.01';

sub available {
    my ( $plugin, $dist ) = @_;
    return ( $dist->parent->package_name eq 'YAML-LibYAML' );
}

sub pre_prepare {
    my ( $plugin, $dist ) = @_;

    my $module = $dist->parent;
    my $cb     = $module->parent;

    my $wrksrc = $module->status->extract;
    if ( !$wrksrc ) {
        return;
    }

    my $filename = File::Spec->catfile( $wrksrc, 'LibYAML', 'Makefile.PL' );
    if ( !-f $filename ) {
        return 1;
    }

    my $non_unique_file_list = qr/^\Q} glob("*.c"), 'LibYAML.c';\E/xms;

    my $unique_file_list
        = '} keys %{{ map { $_ => 1 } glob("*.c"), "LibYAML.c" }};';

    my $makefile_pl = $dist->_read_file($filename);
    return if !defined $makefile_pl;
    if ( $makefile_pl =~ s/$non_unique_file_list/$unique_file_list/ ) {
        $cb->_move( file => $filename, to => "$filename.orig" ) or return;
        $dist->_write_file( $filename, $makefile_pl ) or return;
    }

    return 1;
}

1;
__END__

=head1 NAME

CPANPLUS::Dist::Slackware::Plugin::YAML::LibYAML - Fix YAML::LibYAML build

=head1 VERSION

This documentation refers to
C<CPANPLUS::Dist::Slackware::Plugin::YAML::LibYAML> version 0.01.

=head1 SYNOPSIS

    $is_available = $plugin->available($dist);
    $success      = $plugin->pre_prepare($dist);

=head1 DESCRIPTION

If YAML::LibYAML is built a second time, the build fails since
F<LibYAML/Makefile.PL> adds F<LibYAML.o> twice to the list of object files.
Reported as bug #74238 at L<http://rt.cpan.org/>.

=head1 SUBROUTINES/METHODS

=over 4

=item B<< $plugin->available($dist) >>

Returns true if this plugin applies to the given distribution.

=item B<< $plugin->pre_prepare($dist) >>

Patches F<LibYAML/Makefile.PL>.  Returns true on success.

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires the module C<File::Spec>.

=head1 INCOMPATIBILITIES

None known.

=head1 SEE ALSO

C<CPANPLUS::Dist::Slackware>

=head1 AUTHOR

Andreas Voegele, C<< <andreas at andreasvoegele.com> >>

=head1 BUGS AND LIMITATIONS

Please report any bugs to C<bug-cpanplus-dist-slackware at rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org/>.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Andreas Voegele

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

See http://dev.perl.org/licenses/ for more information.

=cut