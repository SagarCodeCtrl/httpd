 
AC_DEFUN(APACHE_CONFIG_NICE,[
  rm -f $1
  cat >$1<<EOF
#! /bin/sh
#
# Created by configure

EOF
  if test -n "$OPTIM"; then
    echo "OPTIM=\"$OPTIM\"; export OPTIM" >> $1
  fi

  for arg in [$]0 "[$]@"; do
    echo "\"[$]arg\" \\" >> $1
  done
  echo '"[$]@"' >> $1
  chmod +x $1
])

AC_DEFUN(APACHE_PASSTHRU,[
  unset ac_cv_pass_$1
  AC_CACHE_VAL(ac_cv_pass_$1, [ac_cv_pass_$1=$$1])
])

dnl APACHE_SUBST(VARIABLE)
dnl Makes VARIABLE available in generated files
dnl (do not use @variable@ in Makefiles, but $(variable))
AC_DEFUN(APACHE_SUBST,[
  APACHE_VAR_SUBST="$APACHE_VAR_SUBST $1"
  AC_SUBST($1)
])

dnl APACHE_FAST_OUTPUT(FILENAME)
dnl Perform substitutions on FILENAME (Makefiles only)
AC_DEFUN(APACHE_FAST_OUTPUT,[
  APACHE_FAST_OUTPUT_FILES="$APACHE_FAST_OUTPUT_FILES $1"
])

dnl APACHE_MKDIR_P_CHECK
dnl checks whether mkdir -p works
AC_DEFUN(APACHE_MKDIR_P_CHECK,[
  AC_CACHE_CHECK(for working mkdir -p, ac_cv_mkdir_p,[
    test -d conftestdir && rm -rf conftestdir
    mkdir -p conftestdir/somedir >/dev/null 2>&1
    if test -d conftestdir/somedir; then
      ac_cv_mkdir_p=yes
    else
      ac_cv_mkdir_p=no
    fi
    rm -rf conftestdir
  ])
])

dnl APACHE_GEN_CONFIG_VARS
dnl Creates config_vars.mk
AC_DEFUN(APACHE_GEN_CONFIG_VARS,[
  APACHE_SUBST(abs_srcdir)
  APACHE_SUBST(bindir)
  APACHE_SUBST(cgidir)
  APACHE_SUBST(logdir)
  APACHE_SUBST(exec_prefix)
  APACHE_SUBST(datadir)
  APACHE_SUBST(localstatedir)
  APACHE_SUBST(libexecdir)
  APACHE_SUBST(htdocsdir)
  APACHE_SUBST(includedir)
  APACHE_SUBST(iconsdir)
  APACHE_SUBST(sysconfdir)
  APACHE_SUBST(other_targets)
  APACHE_SUBST(progname)
  APACHE_SUBST(prefix)
  APACHE_SUBST(AWK)
  APACHE_SUBST(CC)
  APACHE_SUBST(CFLAGS)
  APACHE_SUBST(CPPFLAGS)
  APACHE_SUBST(CXX)
  APACHE_SUBST(CXXFLAGS)
  APACHE_SUBST(LTFLAGS)
  APACHE_SUBST(LDFLAGS)
  APACHE_SUBST(DEFS)
  APACHE_SUBST(LIBTOOL)
  APACHE_SUBST(SHELL)
  APACHE_SUBST(MODULE_DIRS)
  APACHE_SUBST(PORT)
  APACHE_SUBST(NOTEST_CFLAGS)
  APACHE_SUBST(NOTEST_LDFLAGS)

  abs_srcdir="`(cd $srcdir && pwd)`"

  APACHE_MKDIR_P_CHECK
  echo creating config_vars.mk
  > config_vars.mk
  for i in $APACHE_VAR_SUBST; do
    eval echo "$i = \$$i" >> config_vars.mk
  done
])

dnl APACHE_GEN_MAKEFILES
dnl Creates Makefiles
AC_DEFUN(APACHE_GEN_MAKEFILES,[
  $SHELL $srcdir/build/fastgen.sh $srcdir $ac_cv_mkdir_p $BSD_MAKEFILE $APACHE_FAST_OUTPUT_FILES
])

AC_DEFUN(APACHE_LIBTOOL_SILENT,[
  LIBTOOL='$(SHELL) $(top_builddir)/libtool --silent'
])

    
dnl ## APACHE_OUTPUT(file)
dnl ## adds "file" to the list of files generated by AC_OUTPUT
dnl ## This macro can be used several times.
AC_DEFUN(APACHE_OUTPUT, [
  APACHE_OUTPUT_FILES="$APACHE_OUTPUT_FILES $1"
])

dnl
dnl AC_ADD_LIBRARY(library)
dnl
dnl add a library to the link line
dnl
AC_DEFUN(AC_ADD_LIBRARY,[
  APACHE_ONCE(LIBRARY, $1, [
    EXTRA_LIBS="$EXTRA_LIBS -l$1"
  ])
])

dnl
dnl AC_CHECK_DEFINE(macro, headerfile)
dnl
dnl checks for the macro in the header file
dnl
AC_DEFUN(AC_CHECK_DEFINE,[
  AC_CACHE_CHECK(for $1 in $2, ac_cv_define_$1,
  AC_EGREP_CPP([YES_IS_DEFINED], [
#include <$2>
#ifdef $1
YES_IS_DEFINED
#endif
  ], ac_cv_define_$1=yes, ac_cv_define_$1=no))
  if test "$ac_cv_define_$1" = "yes" ; then
      AC_DEFINE(HAVE_$1,,
          [Define if the macro "$1" is defined on this system])
  fi
])

dnl
dnl AC_TYPE_RLIM_T
dnl
dnl If rlim_t is not defined, define it to int
dnl
AC_DEFUN(AC_TYPE_RLIM_T, [
  AC_CACHE_CHECK([for rlim_t], ac_cv_type_rlim_t, [
    AC_TRY_COMPILE([
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
], [rlim_t spoon;], [
      ac_cv_type_rlim_t=yes
    ],[ac_cv_type_rlim_t=no
    ])
  ])
  if test "$ac_cv_type_rlim_t" = "no" ; then
      AC_DEFINE(rlim_t, int,
          [Define to 'int' if <sys/resource.h> doesn't define it for us])
  fi
])

dnl
dnl APACHE_ONCE(namespace, variable, code)
dnl
dnl execute code, if variable is not set in namespace
dnl
AC_DEFUN(APACHE_ONCE,[
  unique=`echo $ac_n "$2$ac_c" | tr -cd a-zA-Z0-9`
  cmd="echo $ac_n \"\$$1$unique$ac_c\""
  if test -n "$unique" && test "`eval $cmd`" = "" ; then
    eval "$1$unique=set"
    $3
  fi
])

sinclude(srclib/apr/apr_common.m4)
sinclude(srclib/apr/hints.m4)
sinclude(hints.m4)

AC_DEFUN(APACHE_CHECK_SIGWAIT_ONE_ARG,[
  AC_CACHE_CHECK(whether sigwait takes one argument,ac_cv_sigwait_one_arg,[
  AC_TRY_COMPILE([
#ifdef __NETBSD__
    /* When using the unproven-pthreads package, we need to pull in this 
     * header to get a prototype for sigwait().  Else things will fail later
     * on.  XXX Should probably be fixed in the unproven-pthreads package.
     */
#include <pthread.h>
#endif
#include <signal.h>
],[
  sigset_t set;

  sigwait(&set);
],[
  ac_cv_sigwait_one_arg=yes
],[
  ac_cv_sigwait_one_arg=no
])])
  if test "$ac_cv_sigwait_one_arg" = "yes"; then
    AC_DEFINE(SIGWAIT_TAKES_ONE_ARG,1,[ ])
  fi
])

dnl APACHE_MODPATH_INIT(modpath)
AC_DEFUN(APACHE_MODPATH_INIT,[
  current_dir=$1
  modpath_current=modules/$1
  modpath_static=
  modpath_shared=
  test -d $1 || $srcdir/build/mkdir.sh $modpath_current
  > $modpath_current/modules.mk
])dnl
dnl
AC_DEFUN(APACHE_MODPATH_FINISH,[
  echo "DISTCLEAN_TARGETS = modules.mk" >> $modpath_current/modules.mk
  echo "static = $modpath_static" >> $modpath_current/modules.mk
  echo "shared = $modpath_shared" >> $modpath_current/modules.mk
  if test ! -z "$modpath_static" -o ! -z "$modpath_shared"; then
    MODULE_DIRS="$MODULE_DIRS $current_dir"
  fi
  APACHE_FAST_OUTPUT($modpath_current/Makefile)
])dnl
dnl
dnl APACHE_MODPATH_ADD(name[, shared[, objects [, ldflags[, libs]]]])
AC_DEFUN(APACHE_MODPATH_ADD,[
  if test -z "$3"; then
    objects="mod_$1.lo"
  else
    objects="$3"
  fi

  if test -z "$module_standalone"; then
    if test -z "$2"; then
      libname="mod_$1.la"
      BUILTIN_LIBS="$BUILTIN_LIBS $modpath_current/$libname"
      modpath_static="$modpath_static $libname"
      cat >>$modpath_current/modules.mk<<EOF
$libname: $objects
	\$(MOD_LINK) $objects
EOF
    else
      apache_need_shared=yes
      libname="mod_$1.la"
      shobjects=`echo $objects | sed 's/\.lo/.slo/'`
      modpath_shared="$modpath_shared $libname"
      cat >>$modpath_current/modules.mk<<EOF
$libname: $shobjects
	\$(SH_LINK) -rpath \$(libexecdir) -module -avoid-version $4 $objects $5
EOF
    fi
  fi
])dnl
dnl
dnl APACHE_MODULE(name, helptext[, objects[, structname[, default[, config]]]])
AC_DEFUN(APACHE_MODULE,[
  AC_MSG_CHECKING(whether to enable mod_$1)
  define([optname],[  --]ifelse($5,yes,disable,enable)[-]translit($1,_,-))dnl
  AC_ARG_ENABLE(translit($1,_,-),optname() substr([                         ],len(optname()))$2,,enable_$1=ifelse($5,,no,$5))
  undefine([optname])dnl
  AC_MSG_RESULT($enable_$1)
  if test "$enable_$1" != "no"; then
    case "$enable_$1" in
    shared*)
      enable_$1=`echo $ac_n $enable_$1$ac_c|sed 's/shared,*//'`
      sharedobjs=yes
      shared=yes;;
    *)
      MODLIST="$MODLIST ifelse($4,,$1,$4)"
      if test "$1" = "so"; then
          sharedobjs=yes
      fi
      shared="";;
    esac
    ifelse([$6],,:,[$6])
    APACHE_MODPATH_ADD($1, $shared, $3)
  fi
])dnl
dnl
dnl APACHE_LAYOUT(configlayout, layoutname)
AC_DEFUN(APACHE_LAYOUT,[
  if test ! -f $srcdir/config.layout; then
    echo "** Error: Layout file $srcdir/../config.layout not found"
    echo "** Error: Cannot use undefined layout '$LAYOUT'"
    exit 1
  fi
  pldconf=config.pld
  changequote({,})
  sed -e "1,/[ 	]*<[lL]ayout[ 	]*$2[ 	]*>[ 	]*/d" \
      -e '/[ 	]*<\/Layout>[ 	]*/,$d' \
      -e "s/^[ 	]*//g" \
      -e "s/:[ 	]*/=\'/g" \
      -e "s/[ 	]*$/'/g" \
      $1 > $pldconf
  layout_name=$2
  . $pldconf
  rm $pldconf
  for var in prefix exec_prefix bindir sbindir libexecdir mandir \
             sysconfdir datadir iconsdir htdocsdir cgidir includedir \
             localstatedir runtimedir logdir proxycachedir; do
    eval "val=\"\$$var\""
    case $val in
      *+)
        val=`echo $val | sed -e 's;\+$;;'`
        eval "$var=\"\$val\""
        autosuffix=yes
        ;;
      *)
        autosuffix=no
        ;;
    esac
    val=`echo $val | sed -e 's:\(.\)/*$:\1:'`
    val=`echo $val | sed -e 's:$\([a-z_]*\):$(\1):g'`
    if test "$autosuffix" = "yes"; then
      if echo $val | grep apache >/dev/null; then
        addtarget=no
      else
        addtarget=yes
      fi
      if test "$addtarget" = "yes"; then
        val="$val/apache"
      fi
    fi
    eval "$var='$val'"
  done
  changequote([,])
])dnl
dnl
dnl APACHE_ENABLE_LAYOUT
dnl
AC_DEFUN(APACHE_ENABLE_LAYOUT,[
AC_ARG_ENABLE(layout,
[  --enable-layout=LAYOUT],[
  LAYOUT=$enableval
])

if test -z "$LAYOUT"; then
  htdocsdir='$(prefix)/htdocs'
  iconsdir='$(prefix)/icons'
  cgidir='$(prefix)/cgi-bin'
  logdir='$(prefix)/logs'
  sysconfdir='${prefix}/conf'
  libexecdir='${prefix}/modules'
  layout_name=Apache
else  
  APACHE_LAYOUT($srcdir/../config.layout, $LAYOUT)
fi

AC_MSG_CHECKING(for chosen layout)
AC_MSG_RESULT($layout_name)
])dnl
dnl
dnl APACHE_ENABLE_SHARED
dnl
AC_DEFUN(APACHE_ENABLE_SHARED,[
AC_ARG_ENABLE(mods-shared,
[  --enable-mods-shared=MODULE-LIST],[
  for i in $enableval; do
  	eval "enable_$i=shared"
  done
])
])dnl
dnl
dnl APACHE_ENABLE_MODULES
dnl
AC_DEFUN(APACHE_ENABLE_MODULES,[
AC_ARG_ENABLE(modules,
[  --enable-modules=MODULE-LIST],[
  for i in $enableval; do
    eval "enable_$i=yes"
  done
])
])dnl

AC_DEFUN(APACHE_REQUIRE_CXX,[
  if test -z "$apache_cxx_done"; then
    AC_PROG_CXX
    AC_PROG_CXXCPP
    apache_cxx_done=yes
  fi
])
