PHP_ARG_WITH(gmagick, whether to enable the gmagick extension,
[  --with-gmagick[=DIR]	Enables the gmagick extension. DIR is the prefix to GraphicsMagick installation directory.], no)

if test $PHP_GMAGICK != "no"; then

		AC_MSG_CHECKING(GraphicsMagick configuration program)
	
		for i in $PHP_GMAGICK /usr/local /usr;
		do
			test -r $i/bin/GraphicsMagick-config && WAND_BINARY=$i/bin/GraphicsMagick-config && break
		done	
		
		if test -z "$WAND_BINARY"; then
			AC_MSG_ERROR(not found. Please provide a path to GraphicsMagick-config program.)
		fi
		
		AC_MSG_RESULT(found in $WAND_BINARY)
		
		AC_MSG_CHECKING(GraphicsMagick version)
		WAND_DIR=`$WAND_BINARY --prefix`

		GRAPHICSMAGICK_VERSION_ORIG=`$WAND_BINARY --version`
		GRAPHICSMAGICK_VERSION_MASK=`echo ${GRAPHICSMAGICK_VERSION_ORIG} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`

		if test "$GRAPHICSMAGICK_VERSION_MASK" -ge 1001000; then
			AC_MSG_RESULT(found version $GRAPHICSMAGICK_VERSION_ORIG)
		else
			AC_MSG_ERROR(no. You need at least GraphicsMagick version 1.1.0 to use Gmagick.)
		fi
		AC_MSG_CHECKING(GraphicsMagick version mask)
		AC_MSG_RESULT(found version $GRAPHICSMAGICK_VERSION_MASK)

		PHP_CHECK_FUNC(omp_pause_resource_all, gomp)

        LIB_DIR=$WAND_DIR/lib
        # If "$LIB_DIR" == "/usr/lib" or possible /usr/$PHP_LIBDIR" then you're probably
        # going to have a bad time. PHP m4 files seem to be hard-coded to not link properly against
        # those directories. See PHP_ADD_LIBPATH for the weirdness.

		PHP_ADD_LIBRARY_WITH_PATH(GraphicsMagick, $LIB_DIR, GMAGICK_SHARED_LIBADD)
		PHP_ADD_LIBRARY_WITH_PATH(GraphicsMagickWand, $LIB_DIR, GMAGICK_SHARED_LIBADD)
		PHP_ADD_INCLUDE($WAND_DIR/include/GraphicsMagick)

		PHP_NEW_EXTENSION(gmagick, gmagick_helpers.c gmagick_methods.c gmagick.c gmagickdraw_methods.c gmagickpixel_methods.c,  $ext_shared)

		PHP_SUBST(GMAGICK_SHARED_LIBADD)	
		AC_DEFINE(HAVE_GMAGICK,1,[ ])
		AC_DEFINE_UNQUOTED(GMAGICK_LIB_MASK,$GRAPHICSMAGICK_VERSION_MASK,[Version mask for comparisons])
fi
