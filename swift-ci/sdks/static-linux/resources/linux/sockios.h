/* ===----------------------------------------------------------------------===

    Swift Static SDK for Linux: <linux/sockios.h> Header Shim

    This source file is part of the Swift.org open source project

    Copyright (c) 2024 Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception

    See https://swift.org/LICENSE.txt for license information
    See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

   ===----------------------------------------------------------------------=== */

/* This contains a couple of SIOC constants that aren't included in
   Musl's <sys/ioctl.h> but that we need for libdispatch. */

#ifndef _LINUX_SOCKIOS_H
#define _LINUX_SOCKIOS_H

#define SIOCINQ         0x541B
#define SIOCOUTQ        0x5411

#endif /* _LINUX_SOCKIOS_H */
