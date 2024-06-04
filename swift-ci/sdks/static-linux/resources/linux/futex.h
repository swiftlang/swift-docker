/* ===----------------------------------------------------------------------===

    Swift Static SDK for Linux: <linux/futex.h> Header Shim

    This source file is part of the Swift.org open source project

    Copyright (c) 2024 Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception

    See https://swift.org/LICENSE.txt for license information
    See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

   ===----------------------------------------------------------------------=== */

/* This just contains the #define values we need to use futexes, and
   nothing else. */

#ifndef _LINUX_FUTEX_H
#define _LINUX_FUTEX_H

#define FUTEX_WAIT                    0
#define FUTEX_WAKE                    1
#define FUTEX_FD                      2
#define FUTEX_REQUEUE                 3
#define FUTEX_CMP_REQUEUE             4
#define FUTEX_WAKE_OP                 5
#define FUTEX_LOCK_PI                 6
#define FUTEX_UNLOCK_PI               7
#define FUTEX_TRYLOCK_PI              8
#define FUTEX_WAIT_BITSET             9
#define FUTEX_WAKE_BITSET             10
#define FUTEX_WAIT_REQUEUE_PI         11
#define FUTEX_CMP_REQUEUE_PI          12

#define FUTEX_PRIVATE_FLAG            128
#define FUTEX_CLOCK_REALTIME          256
#define FUTEX_CMD_MASK                ~(FUTEX_PRIVATE_FLAG | FUTEX_CLOCK_REALTIME)

#define FUTEX_WAIT_PRIVATE            (FUTEX_WAIT | FUTEX_PRIVATE_FLAG)
#define FUTEX_WAKE_PRIVATE            (FUTEX_WAKE | FUTEX_PRIVATE_FLAG)
#define FUTEX_REQUEUE_PRIVATE         (FUTEX_REQUEUE | FUTEX_PRIVATE_FLAG)
#define FUTEX_CMP_REQUEUE_PRIVATE     (FUTEX_CMP_REQUEUE | FUTEX_PRIVATE_FLAG)
#define FUTEX_WAKE_OP_PRIVATE         (FUTEX_WAKE_OP | FUTEX_PRIVATE_FLAG)
#define FUTEX_LOCK_PI_PRIVATE         (FUTEX_LOCK_PI | FUTEX_PRIVATE_FLAG)
#define FUTEX_UNLOCK_PI_PRIVATE       (FUTEX_UNLOCK_PI | FUTEX_PRIVATE_FLAG)
#define FUTEX_TRYLOCK_PI_PRIVATE      (FUTEX_TRYLOCK_PI | FUTEX_PRIVATE_FLAG)
#define FUTEX_WAIT_BITSET_PRIVATE     (FUTEX_WAIT_BITSET | FUTEX_PRIVATE_FLAG)
#define FUTEX_WAKE_BITSET_PRIVATE     (FUTEX_WAKE_BITSET | FUTEX_PRIVATE_FLAG)
#define FUTEX_WAIT_REQUEUE_PI_PRIVATE (FUTEX_WAIT_REQUEUE_PI | FUTEX_PRIVATE_FLAG)
#define FUTEX_CMP_REQUEUE_PI_PRIVATE  (FUTEX_CMP_REQUEUE_PI | FUTEX_PRIVATE_FLAG)

#define FUTEX_TID_MASK                0x3fffffff
#define FUTEX_OWNER_DIED              0x40000000
#define FUTEX_WAITERS                 0x80000000

#define FUTEX_OP_SET                  0
#define FUTEX_OP_ADD                  1
#define FUTEX_OP_OR                   2
#define FUTEX_OP_ANDN                 3
#define FUTEX_OP_XOR                  4

#define FUTEX_OP_OPARG_SHIFT          8

#define FUTEX_OP_CMP_EQ               0
#define FUTEX_OP_CMP_NE               1
#define FUTEX_OP_CMP_LT               2
#define FUTEX_OP_CMP_LE               3
#define FUTEX_OP_CMP_GT               4
#define FUTEX_OP_CMP_GE               5

#endif /* _LINUX_FUTEX_H */
