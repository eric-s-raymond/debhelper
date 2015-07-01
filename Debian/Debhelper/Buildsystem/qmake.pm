# A debhelper build system class for Qt projects
# (based on the makefile class).
#
# Copyright: © 2010 Kelvin Modderman
# License: GPL-2+

package Debian::Debhelper::Buildsystem::qmake;

use strict;
use warnings;
use Debian::Debhelper::Dh_Lib qw(error);
use parent qw(Debian::Debhelper::Buildsystem::makefile);

our $qmake="qmake";

sub DESCRIPTION {
	"qmake (*.pro)";
}

sub check_auto_buildable {
	my $this=shift;
	my @projects=glob($this->get_sourcepath('*.pro'));
	my $ret=0;

	if (@projects > 0) {
		$ret=1;
		# Existence of a Makefile generated by qmake indicates qmake
		# class has already been used by a prior build step, so should
		# be used instead of the parent makefile class.
		my $mf=$this->get_buildpath("Makefile");
		if (-e $mf) {
			$ret = $this->SUPER::check_auto_buildable(@_);
			open(my $fh, '<', $mf)
				or error("unable to open Makefile: $mf");
			while(<$fh>) {
				if (m/^# Generated by qmake/i) {
					$ret++;
					last;
				}
			}
			close($fh);
		}
	}

	return $ret;
}

sub configure {
	my $this=shift;
	my @options;
	my @flags;

	push @options, '-makefile';
	push @options, '-nocache';

	if ($ENV{CFLAGS}) {
		push @flags, "QMAKE_CFLAGS_RELEASE=$ENV{CFLAGS} $ENV{CPPFLAGS}";
		push @flags, "QMAKE_CFLAGS_DEBUG=$ENV{CFLAGS} $ENV{CPPFLAGS}";
	}
	if ($ENV{CXXFLAGS}) {
		push @flags, "QMAKE_CXXFLAGS_RELEASE=$ENV{CXXFLAGS} $ENV{CPPFLAGS}";
		push @flags, "QMAKE_CXXFLAGS_DEBUG=$ENV{CXXFLAGS} $ENV{CPPFLAGS}";
	}
	if ($ENV{LDFLAGS}) {
		push @flags, "QMAKE_LFLAGS_RELEASE=$ENV{LDFLAGS}";
		push @flags, "QMAKE_LFLAGS_DEBUG=$ENV{LDFLAGS}";
	}
	push @flags, "QMAKE_STRIP=:";
	push @flags, "PREFIX=/usr";

	$this->doit_in_builddir($qmake, @options, @flags, @_);
}

sub install {
	my $this=shift;
	my $destdir=shift;

	# qmake generated Makefiles use INSTALL_ROOT in install target
	# where one would expect DESTDIR to be used.
	$this->SUPER::install($destdir, "INSTALL_ROOT=$destdir", @_);
}

1

# Local Variables:
# indent-tabs-mode: t
# tab-width: 4
# cperl-indent-level: 4
# End:
