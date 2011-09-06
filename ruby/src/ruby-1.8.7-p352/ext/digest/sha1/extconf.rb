# $RoughId: extconf.rb,v 1.3 2001/08/14 19:54:51 knu Exp $
# $Id: extconf.rb 11708 2007-02-12 23:01:19Z shyouhei $

require "mkmf"

$defs << "-DHAVE_CONFIG_H"
$INCFLAGS << " -I$(srcdir)/.."

$objs = [ "sha1init.#{$OBJEXT}" ]

dir_config("openssl")

if !with_config("bundled-sha1") &&
    have_library("crypto") && have_header("openssl/sha.h")
  $objs << "sha1ossl.#{$OBJEXT}"
else
  $objs << "sha1.#{$OBJEXT}"
end

have_header("sys/cdefs.h")

have_header("inttypes.h")

have_header("unistd.h")

$preload = %w[digest]

create_makefile("digest/sha1")
