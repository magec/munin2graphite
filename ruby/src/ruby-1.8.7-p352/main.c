/**********************************************************************

  main.c -

  $Author: shyouhei $
  $Date: 2007-02-13 08:01:19 +0900 (Tue, 13 Feb 2007) $
  created at: Fri Aug 19 13:19:58 JST 1994

  Copyright (C) 1993-2003 Yukihiro Matsumoto

**********************************************************************/

#include "ruby.h"

#ifdef __human68k__
int _stacksize = 262144;
#endif

#if defined __MINGW32__
int _CRT_glob = 0;
#endif

#if defined(__MACOS__) && defined(__MWERKS__)
#include <console.h>
#endif

/* to link startup code with ObjC support */
#if (defined(__APPLE__) || defined(__NeXT__)) && defined(__MACH__)
static void objcdummyfunction( void ) { objc_msgSend(); }
#endif

int
main(argc, argv, envp)
    int argc;
    char **argv, **envp;
{
#ifdef _WIN32
    NtInitialize(&argc, &argv);
#endif
#if defined(__MACOS__) && defined(__MWERKS__)
    argc = ccommand(&argv);
#endif

    {
        RUBY_INIT_STACK
        ruby_init();
        ruby_options(argc, argv);
        ruby_run();
    }
    return 0;
}
