/* ===----------------------------------------------------------------------===

    Swift Static SDK for Linux: <linux/vm_sockets.h> Header Shim

    This source file is part of the Swift.org open source project

    Copyright (c) 2024 Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception

    See https://swift.org/LICENSE.txt for license information
    See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

   ===----------------------------------------------------------------------=== */

/* This contains some VMWare vSockets constants and structs that are needed by
   Swift NIO. */

#ifndef _LINUX_VM_SOCKETS_H
#define _LINUX_VM_SOCKETS_H

// The official one doesn't actually include this, but probably should
#include <sys/socket.h>

#define SO_VM_SOCKETS_NONBLOCK_TXRX 7

#define VMADDR_CID_ANY -1U
#define VMADDR_PORT_ANY -1U

#define VMADDR_CID_HYPERVISOR 0
#define VMADDR_CID_LOCAL 1
#define VMADDR_CID_HOST 2

#define VM_SOCKETS_INVALID_VERSION -1U

#define IOCTL_VM_SOCKETS_GET_LOCAL_CID 0x07b9

struct sockaddr_vm {
  sa_family_t svm_family;
  unsigned short svm_reserved1;
  unsigned int svm_port;
  unsigned int svm_cid;
  unsigned char svm_zero[sizeof(struct sockaddr)
                         - sizeof(sa_family_t)
                         - sizeof(unsigned short)
                         - sizeof(unsigned int)
                         - sizeof(unsigned int)];
};

#endif /* _LINUX_VM_SOCKETS_H */
