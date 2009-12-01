# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.0-r1.ebuild,v 1.4 2009/11/29 16:02:40 klausman Exp $

EAPI="2"

inherit confutils eutils autotools

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/talloc/${P}.tar.gz"
LICENSE="GPL-3"
IUSE="compat doc python"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~x86"

DEPEND="
	doc? ( app-text/docbook-xml-dtd:4.2 )
	!<net-fs/samba-libs-3.4
	"
RDEPEND="${DEPEND}"

src_prepare() {

	epatch "${FILESDIR}"/${P}-without-doc.patch
	epatch "${FILESDIR}"/${P}-enable-python.patch
	eautoconf -Ilibreplace
	sed -e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' -i Makefile.in
}

src_configure() {

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable compat talloc-compat1) \
		$(use_enable python) \
		$(use_with doc) \
	|| die "econf failed"

}

src_compile() {

	emake showflags || die "emake showflags failed"
	emake shared-build || die "emake shared-build failed"

}

src_install() {

	emake install DESTDIR="${D}" || die "emake install failed"
	dolib.a sharedbuild/lib/libtalloc.a
	dolib.so sharedbuild/lib/libtalloc.so

}