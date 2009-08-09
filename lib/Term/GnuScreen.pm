package Term::GnuScreen;

use Moose;
use Sub::Install qw(install_sub);
use File::Temp qw(tmpnam);
use autodie qw(:all);
use File::Which;
use IO::CaptureOutput qw(capture);

our $VERSION = '0.01';

BEGIN {

	my @commands = ( qw( acladd aclchg acldel aclgrp aclumask activity addacl allpartial
	altscreen at attrcolor autodetach autonuke backtick bce bell_msg 
	bindkey blanker blankerprg break breaktype bufferfile c1 caption chacl
	charset clear colon command compacthist console copy copy_reg
	crlf debug defautonuke defbce defbreaktype defc1 defcharset defencoding
	defescape defflow defgr defhstatus deflog deflogin defmode defmonitor
	defnonblock defobuflimit defscrollback defshell defsilence defslowpaste
	defutf8 defwrap defwritelock defzombie detach digraph dinfo displays
	dumptermcap echo encoding escape eval fit flow focus gr 
	hardcopy_append hardcopydir hardstatus height help history hstatus idle
	ignorecase info ins_reg kill lastmsg license lockscreen log logfile login
	logtstamp mapdefault mapnotnext maptimeout markkeys maxwin monitor
	msgminwait msgwait multiuser nethack next nonblock number obuflimit only
	other partial password paste pastefont pow_break pow_detach pow_detach_msg
	prev printcmd process quit readbuf readreg redisplay register remove
	removebuf reset resize screen scrollback select sessionname setenv setsid
	shell shelltitle silence silencewait sleep slowpaste source sorendition
	split startup_message stuff su suspend term termcap terminfo termcapinfo
	time title unsetenv utf8 vbell vbell_msg vbellwait version wall
	width windowlist windows wrap writebuf writelock xoff xon zmodem zombie ) );

	for my $name (@commands) {
		install_sub({
			code => sub { shift->send_command($name,@_) },
			as   => $name
		});
	}

	my @rcommands = ( qw( bind meta chdir exec umask) );

	for my $name (@rcommands) {
		install_sub({
			code => sub { shift->send_command($name,@_) },
			as   => "s$name"
		});
	}
}

has session    => (is => 'rw', isa => 'Str' );
has window     => (is => 'rw', isa => 'Str' );
has executable => (is => 'rw', isa => 'Str', default => sub { which("screen") } );

sub send_command {
	my ($self,$cmd,@args) = @_;
	my @screencmd = ( $self->executable );
	push @screencmd, '-S', $self->session if $self->session;
	push @screencmd, '-p', $self->window if $self->window;

	my ($stdout,$stderr);
	eval { 
		capture { system(@screencmd, '-X', $cmd, @args) } \$stdout, \$stderr;
		1;
	} or do {
		my $err;# = $!;
		$err = $stderr if defined $stderr;
		$err = $stdout if defined $stdout; # '*err*, stdout seems to be actual more helpful
		die "$err";
	};
	return 1;
}

sub hardcopy {
	my ($self,$file) = @_;
	if (!$file) {
		$file = tmpnam();
	}
	$self->send_command('hardcopy',$file);
	return $file;
}

1;

__END__


=head1 NAME

Term::GnuScreen - Control GNU screen via perl

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Term::GnuScreen provides a simple interface to control a GNU screen
session via its command line interface.

    use Term::GnuScreen;

    my $screen = Term::GnuScreen->new();
    $screen->windowlist;
    $screen->hardcopy('/tmp/my_hardcopy');

=head1 METHODS

Term::GnuScreen implements all commands as stated in the texinfo document
shipped with GNU screen. To call a commands, it's send via GNU screens -X
paramter to the first running screen session and its current window. You
can change session and window with the according object methods and
construction paramters. Unless listed here, all remaining arguments are
handled over to screen.

The five commands bind, meta, chdir, exec and umask are prefixed with
a I<s> to distinguish them from the built-ins with the same name.

=head2 send_command

This command is the working horse of Term::GnuScreen. It simply build
the command line to call and add all the supplied arguments to screens -X.

=head2 hardcopy

Write a hardcopy of the current window to a temporary file and returns
the filename unless the filename is supplied as first argument.

=head1 ERROR HANDLING

Simple dies in case screen -X did not return with a return value of
zero. Either $!, STDERR or STDOUT (which seems to be more helpful
most times) are provided as error message for further investigation.

=head1 AUTHOR

Mario Domgoergen, C<< <dom at math.uni-bonn.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-term-gnuscreen at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Term-GnuScreen>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::GnuScreen


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Term-GnuScreen>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Term-GnuScreen>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Term-GnuScreen>

=item * Search CPAN

L<http://search.cpan.org/dist/Term-GnuScreen>

=back


=head1 ACKNOWLEDGEMENTS

L<screen>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Mario Domgoergen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
