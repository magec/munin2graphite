
SHELL = /bin/sh

#### Start of system configuration section. ####
top_srcdir = $(topdir)/.
srcdir = $(top_srcdir)/ext/openssl
topdir = ../..
hdrdir = $(top_srcdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
RUBYLIB = -
RUBYOPT = -rpurelib.rb
exec_prefix = $(prefix)
prefix = $(DESTDIR)/server/graphite/ruby//rubies/ruby-1.8.7-p352
sharedstatedir = $(prefix)/com
mandir = $(datarootdir)/man
psdir = $(docdir)
oldincludedir = $(DESTDIR)/usr/include
localedir = $(datarootdir)/locale
bindir = $(exec_prefix)/bin
libexecdir = $(exec_prefix)/libexec
sitedir = $(libdir)/ruby/site_ruby
htmldir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
includedir = $(prefix)/include
infodir = $(datarootdir)/info
vendorlibdir = $(vendordir)/$(ruby_version)
sysconfdir = $(prefix)/etc
libdir = $(exec_prefix)/lib
sbindir = $(exec_prefix)/sbin
rubylibdir = $(libdir)/ruby/$(ruby_version)
docdir = $(datarootdir)/doc/$(PACKAGE)
dvidir = $(docdir)
vendordir = $(libdir)/ruby/vendor_ruby
datarootdir = $(prefix)/share
pdfdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
sitearchdir = $(sitelibdir)/$(sitearch)
datadir = $(datarootdir)
localstatedir = $(prefix)/var
sitelibdir = $(sitedir)/$(ruby_version)

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = extconf.h
CFLAGS   =  -fPIC -g -O2  -fPIC $(cflags) 
INCFLAGS = -I. -I../.. -I../../. -I../.././ext/openssl
DEFS     = 
CPPFLAGS = -DRUBY_EXTCONF_H=\"$(RUBY_EXTCONF_H)\"   
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  -rdynamic -Wl,-export-dynamic
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = $(topdir)/miniruby -I'$(topdir)' -I'$(top_srcdir)/lib' -I'$(extout)/$(arch)' -I'$(extout)/common' -I./- -I'$(top_srcdir)/ext' -rpurelib.rb
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(topdir)
LIBPATH =  -L. -L$(topdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = $(topdir)/.ext
extout_prefix = $(extout)$(target_prefix)/
target_prefix = 
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) -lssl -lcrypto  -lrt -ldl -lcrypt -lm   -lc
SRCS = ossl_pkey_rsa.c ossl_ns_spki.c ossl_x509.c ossl_pkcs7.c ossl_x509name.c ossl_x509revoked.c ossl_bio.c ossl_bn.c ossl_hmac.c ossl_x509attr.c ossl_config.c ossl_rand.c ossl_x509req.c ossl_pkcs12.c ossl_ssl_session.c ossl_x509cert.c ossl_ssl.c ossl.c ossl_x509crl.c ossl_engine.c ossl_cipher.c ossl_x509store.c openssl_missing.c ossl_pkcs5.c ossl_pkey_dsa.c ossl_digest.c ossl_asn1.c ossl_pkey.c ossl_ocsp.c ossl_pkey_dh.c ossl_x509ext.c ossl_pkey_ec.c
OBJS = ossl_pkey_rsa.o ossl_ns_spki.o ossl_x509.o ossl_pkcs7.o ossl_x509name.o ossl_x509revoked.o ossl_bio.o ossl_bn.o ossl_hmac.o ossl_x509attr.o ossl_config.o ossl_rand.o ossl_x509req.o ossl_pkcs12.o ossl_ssl_session.o ossl_x509cert.o ossl_ssl.o ossl.o ossl_x509crl.o ossl_engine.o ossl_cipher.o ossl_x509store.o openssl_missing.o ossl_pkcs5.o ossl_pkey_dsa.o ossl_digest.o ossl_asn1.o ossl_pkey.o ossl_ocsp.o ossl_pkey_dh.o ossl_x509ext.o ossl_pkey_ec.o
TARGET = openssl
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = $(TARGET).a

BINDIR        = $(extout)/bin
RUBYCOMMONDIR = $(extout)/common
RUBYLIBDIR    = $(RUBYCOMMONDIR)$(target_prefix)
RUBYARCHDIR   = $(extout)/$(arch)$(target_prefix)

TARGET_SO     = $(RUBYARCHDIR)/$(DLLIB)
CLEANLIBS     = $(RUBYARCHDIR)/$(TARGET).so $(RUBYARCHDIR)/$(TARGET).il? $(RUBYARCHDIR)/$(TARGET).tds $(RUBYARCHDIR)/$(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		install
static:		$(STATIC_LIB) install-rb

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
pre-install-rb-default: $(RUBYLIBDIR)/net
install-rb-default: $(RUBYLIBDIR)/net/ftptls.rb
$(RUBYLIBDIR)/net/ftptls.rb: $(srcdir)/lib/net/ftptls.rb $(RUBYLIBDIR)/net
	$(COPY) $(srcdir)/lib/net/ftptls.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/net/telnets.rb
$(RUBYLIBDIR)/net/telnets.rb: $(srcdir)/lib/net/telnets.rb $(RUBYLIBDIR)/net
	$(COPY) $(srcdir)/lib/net/telnets.rb $(@D)
pre-install-rb-default: $(RUBYLIBDIR)
install-rb-default: $(RUBYLIBDIR)/openssl.rb
$(RUBYLIBDIR)/openssl.rb: $(srcdir)/lib/openssl.rb $(RUBYLIBDIR)
	$(COPY) $(srcdir)/lib/openssl.rb $(@D)
pre-install-rb-default: $(RUBYLIBDIR)/openssl
install-rb-default: $(RUBYLIBDIR)/openssl/bn.rb
$(RUBYLIBDIR)/openssl/bn.rb: $(srcdir)/lib/openssl/bn.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/bn.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/ssl.rb
$(RUBYLIBDIR)/openssl/ssl.rb: $(srcdir)/lib/openssl/ssl.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/ssl.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/digest.rb
$(RUBYLIBDIR)/openssl/digest.rb: $(srcdir)/lib/openssl/digest.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/digest.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/pkcs7.rb
$(RUBYLIBDIR)/openssl/pkcs7.rb: $(srcdir)/lib/openssl/pkcs7.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/pkcs7.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/x509.rb
$(RUBYLIBDIR)/openssl/x509.rb: $(srcdir)/lib/openssl/x509.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/x509.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/ssl-internal.rb
$(RUBYLIBDIR)/openssl/ssl-internal.rb: $(srcdir)/lib/openssl/ssl-internal.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/ssl-internal.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/buffering.rb
$(RUBYLIBDIR)/openssl/buffering.rb: $(srcdir)/lib/openssl/buffering.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/buffering.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/config.rb
$(RUBYLIBDIR)/openssl/config.rb: $(srcdir)/lib/openssl/config.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/config.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/x509-internal.rb
$(RUBYLIBDIR)/openssl/x509-internal.rb: $(srcdir)/lib/openssl/x509-internal.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/x509-internal.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/openssl/cipher.rb
$(RUBYLIBDIR)/openssl/cipher.rb: $(srcdir)/lib/openssl/cipher.rb $(RUBYLIBDIR)/openssl
	$(COPY) $(srcdir)/lib/openssl/cipher.rb $(@D)
$(RUBYARCHDIR):
	$(MAKEDIRS) $@
$(RUBYLIBDIR)/net:
	$(MAKEDIRS) $@
$(RUBYLIBDIR):
	$(MAKEDIRS) $@
$(RUBYLIBDIR)/openssl:
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(RUBYARCHDIR)/$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	@-$(MAKEDIRS) $(@D)
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)

$(STATIC_LIB): $(OBJS)
	$(AR) cru $@ $(OBJS)
	@-ranlib $(DLLIB) 2> /dev/null || true

$(OBJS): ruby.h defines.h $(topdir)/config.h $(RUBY_EXTCONF_H)
