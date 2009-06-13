# A buildsystem plugin for building Python Distutils based
# projects.
#
# Copyright: © 2008 Joey Hess
#            © 2008-2009 Modestas Vainius
# License: GPL-2+

package Debian::Debhelper::Buildsystem::python_distutils;

use strict;
use base 'Debian::Debhelper::Buildsystem';

sub DESCRIPTION {
	"Python distutils"
}

sub check_auto_buildable {
	my $this=shift;
	return -e $this->get_sourcepath("setup.py");
}

sub setup_py {
	my $this=shift;
	my $act=shift;

	if ($this->get_builddir()) {
		unshift @_, "--build-base=" . $this->get_build_rel2sourcedir();
	}
	$this->doit_in_sourcedir("python", "setup.py", $act, @_);
}

sub build {
	my $this=shift;
	$this->setup_py("build", @_);
}

sub install {
	my $this=shift;
	my $destdir=shift;
	$this->setup_py("install", "--root=$destdir", "--no-compile", "-O0", @_);
}

sub clean {
	my $this=shift;
	$this->setup_py("clean", "-a", @_);
	# The setup.py might import files, leading to python creating pyc
	# files.
	$this->doit_in_sourcedir('find', '.', '-name', '*.pyc', '-exec', 'rm', '{}', ';');
}

1;