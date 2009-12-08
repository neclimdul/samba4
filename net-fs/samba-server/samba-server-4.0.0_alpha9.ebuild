# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools

MY_PV="${PV/_alpha/alpha}"
MY_P="samba-${MY_PV}"

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug dso gnutls +netapi sqlite threads"

DEPEND="!<net-fs/samba-3.3
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	caps? ( sys-libs/libcap )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )
	~net-fs/samba-libs-${PV}[caps?,debug?,dso?,gnutls?,netapi?,sqlite?,threads?]
	>=sys-libs/talloc-2.0.0
	>=sys-libs/tdb-1.1.7
	=sys-libs/tevent-0.9.8"
	#=sys-libs/ldb-0.9.9 No release yet
# See source4/min_versions.m4 for the minimal versions

RDEPEND="${DEPEND}"

RESTRICT="test mirror"

S="${WORKDIR}/${MY_P}/source4"

SBINPROGS="bin/samba"

src_prepare() {
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I.
}

src_configure() {
	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf \
		--sysconfdir=/etc \
		--localstatedir=/var \
		$(use_enable debug) \
		--enable-developer \
		$(use_enable dso) \
		--disable-external-heimdal \
		--enable-external-libtalloc \
		--enable-external-libtdb \
		--enable-external-libtevent \
		--disable-external-libldb \
		--enable-fhs \
		--enable-largefile \
		$(use_enable gnutls) \
		$(use_enable netapi) \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--with-modulesdir=/usr/lib/samba/modules \
		--with-privatedir=/var/lib/samba/private \
		--with-ntp-signd-socket-dir=/var/run/samba \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--with-piddir=/var/run/samba \
		--without-included-popt \
		$(use_with sqlite sqlite3) \
		$(use_with threads pthreads) \
		--with-setproctitle \
		--with-readline
}

src_compile() {
	# compile server components
	emake basics || die "emake basics failed"
	emake ${SBINPROGS} || die "emake SBINPROGS failed"
}

src_install() {
	# install server components
	dosbin ${SBINPROGS} || die "installing sbinprogs failed"

	# FIXME: install init scripts and such
}

pkg_postinst() {
	ewarn "Samba 4 is an alpha and therefore not considered stable. It's only"
	ewarn "meant to test and experiment and definitely not for production"
}
