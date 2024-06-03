/* ===----------------------------------------------------------------------===

    Swift Static SDK for Linux: <linux/random.h> Header Shim

    This source file is part of the Swift.org open source project

    Copyright (c) 2024 Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception

    See https://swift.org/LICENSE.txt for license information
    See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

   ===----------------------------------------------------------------------=== */

/* This just contains constants needed to build BoringSSL */

#ifndef _LINUX_RANDOM_H
#define _LINUX_RANDOM_H

#include <sys/random.h>

#define RNDGETENTCNT   0x80045200
#define RNDADDTOENTCNT 0x40045201
#define RNDGETPOOL     0x80085202
#define RNDADDENTROPY  0x40085203
#define RNDZAPENTCNT   0x5204
#define RNDCLEARPOOL   0x5206
#define RNDRESEEDCRNG  0x5207

#endif /* _LINUX_RANDOM_H */
