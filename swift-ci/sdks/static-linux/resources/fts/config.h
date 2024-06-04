/* Configure definitions for Musl */

#ifndef FTS_CONFIG_H_
#define FTS_CONFIG_H_

// We have dirfd(), in <dirent.h>
#define HAVE_DIRFD 1

// MAX is defined in <sys/param.h>
#define HAVE_DECL_MAX 1

// UINTMAX_MAX is in <stdint.h>
#define HAVE_DECL_UINTMAX_MAX 1

// We don't have d_namlen
//#undef HAVE_STRUCT_DIRENT_D_NAMLEN

// DIR is opaque
//#undef HAVE_DIR_DD_FD
//#undef HAVE_DIR_D_FD

#endif /* FTS_CONFIG_H_ */
