/* ===----------------------------------------------------------------------===

    Swift Static SDK for Linux: <linux/limits.h> Header Shim

    This source file is part of the Swift.org open source project

    Copyright (c) 2024 Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception

    See https://swift.org/LICENSE.txt for license information
    See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

   ===----------------------------------------------------------------------=== */

/* This just includes <limits.h> so we can pick up PATH_MAX from Musl's header. */

#ifndef _LINUX_LIMITS_H
#define _LINUX_LIMITS_H

#include <limits.h>

#endif /* _LINUX_LIMITS_H */
