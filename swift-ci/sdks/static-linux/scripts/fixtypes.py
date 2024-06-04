#!/usr/bin/env python3

# ===----------------------------------------------------------------------===
#
#  Swift Static SDK for Linux: Fix-up Types for Musl Headers
#
#  This source file is part of the Swift.org open source project
#
#  Copyright (c) 2024 Apple Inc. and the Swift project authors
#  Licensed under Apache License v2.0 with Runtime Library Exception
#
#  See https://swift.org/LICENSE.txt for license information
#  See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ===----------------------------------------------------------------------===

import re
import os
import sys

class Definition (object):
    """Represents a named definition, which may have conditions attached."""

    def __init__(self, name, definition):
        self.conditions = None
        self.name = name
        self.definition = definition

    def conditionalised(self, s):
        """Output a sequence of nested `#if` conditions, as required, with
        the text from `s` in the middle."""

        if self.conditions is None:
            return s
        result = []
        indent = 0
        for cond in self.conditions:
            result.append('{}#if {}'.format('  ' * indent, cond))
            indent += 1
        for line in s.splitlines():
            result.append('  ' * indent + line)
        for cond in reversed(self.conditions):
            indent -= 1
            result.append('{}#endif // {}'.format('  ' * indent, cond))
        return '\n'.join(result)

class Type (Definition):
    """Represents a `typedef`, which might require a `struct`."""

    def __init__(self, name, definition):
        super().__init__(name, definition)
        self.requires = None

    def with_requires(self, s):
        result = []

        if self.requires:
            for require in self.requires:
                result.append('#include "{}.h"'.format(require))

            result.append('')

        result.append(s)

        return self.conditionalised('\n'.join(result))

    def __str__(self):
        return self.with_requires(
            'typedef {} {};'.format(self.definition, self.name)
        )

class Struct (Type):
    def __str__(self):
        return self.with_requires(
            'struct {} {};'.format(self.name, self.definition)
        )

class Define (Definition):
    def __str__(self):
        return self.conditionalised(
            '#define {} {}'.format(self.name, self.definition)
        )

_define_re = re.compile(r'^#define (?P<name>[_A-Za-z][_A-Za-z0-9]*) (?P<definition>.*)$')
_undef_re = re.compile(r'^#undef (?P<name>[_A-Za-z][_A-Za-z0-9]*)(?: |$)')
_if_re = re.compile(r'^#if (?P<condition>.*)$')
_ifdef_re = re.compile(r'^#ifdef (?P<name>[_A-Za-z][_A-Za-z0-9]*)$')
_ifndef_re = re.compile(r'^#ifndef (?P<name>[_A-Za-z][_A-Za-z0-9]*)$')
_else_re = re.compile(r'^#else(?: |$)')
_elif_re = re.compile(r'^#elif (?P<condition>.*)$')
_endif_re = re.compile(r'^#endif(?: |$)')
_typedef_re = re.compile(r'^TYPEDEF (?P<definition>.*) (?P<name>[_A-Za-z][_A-Za-z0-9]*);')
_struct_re = re.compile(r'^STRUCT (?P<name>[_A-Za-z][_A-Za-z0-9]*) (?P<definition>.*);')
_typedef_struct_re = re.compile(r'^TYPEDEF (?P<definition>struct (?P<struct_name>[_A-Za-z][_A-Za-z0-9]*)) (?P<name>[_A-Za-z][_A-Za-z0-9]*);')
_token_re = re.compile(r'[_A-Za-z][_A-Za-z0-9]*')

def fix_types(arch_types, libc_types, defs_output, alltypes_output, output_dir):
    """Take Musl's alltypes.h.in and process it into a set of discrete
       header files, one per type, so that it's modularizable."""

    defines=dict()
    types=dict()
    conditions=[]

    def expand_def(match):
        name = match.group(0)
        repl = defines.get(name, None)
        if repl is None or repl[0].conditions:
            return name
        return repl[0].definition

    def expand(text):
        return _token_re.sub(expand_def, text)

    def scan_requires(text):
        requires = set()
        for match in _token_re.finditer(text):
            token = match.group(0)
            if token in types:
                requires.add(token)
        return list(requires)

    def add_type(type, name=None):
        if name is None:
            name = type.name
        curtypes = types.get(name, [])
        for curt in curtypes:
            if curt.conditions == type.conditions:
                return
        types[name] = curtypes + [type]

    def process(line):
        line = line.strip()

        m = _define_re.match(line)
        if m:
            d = Define(m.group('name'), m.group('definition'))
            if conditions:
                d.conditions = conditions.copy()
            defines[d.name] = defines.get(d.name, []) + [d]
            return

        m = _undef_re.match(line)
        if m:
            del defines[m.group('name')]
            return

        m = _typedef_struct_re.match(line)
        if m:
            t = Type(m.group('name'), expand(m.group('definition')))
            t.requires = ['struct_' + m.group('struct_name')] \
                + scan_requires(m.group('definition'))
            if conditions:
                t.conditions = conditions.copy()
            add_type(t)
            return

        m = _typedef_re.match(line)
        if m:
            t = Type(m.group('name'), expand(m.group('definition')))
            t.requires = scan_requires(m.group('definition'))
            if conditions:
                t.conditions = conditions.copy()
            add_type(t)
            return

        m = _struct_re.match(line)
        if m:
            s = Struct(m.group('name'), expand(m.group('definition')))
            s.requires = scan_requires(m.group('definition'))
            if conditions:
                s.conditions = conditions.copy()
            add_type(s, name='struct_' + s.name)
            return

        m = _if_re.match(line)
        if m:
            conditions.append(m.group('condition'))
            return
        m = _ifdef_re.match(line)
        if m:
            condition = 'defined({})'.format(m.group('name'))
            conditions.append(condition)
            return
        m = _ifndef_re.match(line)
        if m:
            condition = '!defined({})'.format(m.group('name'))
            conditions.append(condition)
            return
        m = _else_re.match(line)
        if m:
            cond = conditions.pop()
            conditions.append('!({})'.format(cond))
            return
        m = _elif_re.match(line)
        if m:
            cond = conditions.pop()
            conditions.append('!({}) && ({})'.format(cond, m.group('condition')))
            return
        m = _endif_re.match(line)
        if m:
            conditions.pop()
            return

    with open(arch_types, "r") as fp:
        for line in fp:
            process(line)
    with open(libc_types, 'r') as fp:
        for line in fp:
            process(line)

    with open(defs_output, 'w') as fp:
        print("""// AUTO-GENERATED FILE: This was generated from alltypes.h.in
#ifndef __BITS_MUSL_DEFS_H
#define __BITS_MUSL_DEFS_H
""", file=fp)

        for _, define in defines.items():
            for d in define:
                print("{}".format(d), file=fp)

        print("""
#endif // __BITS_MUSL_DEFS_H
""", file=fp)

    with open(alltypes_output, 'w') as fp:
        print("""// AUTO-GENERATED FILE: This was generated from alltypes.h.in

#include <bits/musldefs.h>""", file=fp)

        for name, _ in types.items():
            print("""
#ifdef __NEED_{}
#include <bits/types/{}>
#endif""".format(name, name + '.h'), file=fp)

    for name, defs in types.items():
        with open(os.path.join(output_dir, name + '.h'), 'w') as fp:
            ucase_name = name.upper()
            print("""// AUTO-GENERATED FILE: This was generated from alltypes.h.in

#ifndef __BITS_TYPES_{}_H
#define __BITS_TYPES_{}_H

#include <bits/musldefs.h>
""".format(ucase_name, ucase_name), file=fp)

            for t in defs:
                print("{}".format(t), file=fp)

            print("\n#endif // __BITS_TYPES_{}_H".format(ucase_name), file=fp)

    print('Found {} types and {} defines'.format(len(types), len(defines)))

def main(argv):
    if len(argv) != 6:
        print("""usage: fixtypes <path-to-arch-alltypes.h.in> <path-to-main-alltypes.h.in> <musldefs-output.h> <alltypes.h> <types-output-dir>

Given an architecture specific `alltypes.h.in` and a main `alltypes.h.in`,
generate a set of header files, one per type, taking into account any
`#if` conditions that may apply.  Also generate a separate header containing
any `#define`s that are found along the way.
""")
        exit(0)

    arch_alltypes = argv[1]
    alltypes = argv[2]
    musldefs_h = argv[3]
    alltypes_h = argv[4]
    types_dir = argv[5]

    musldefs_dir = os.path.dirname(musldefs_h)
    if musldefs_dir and musldefs_dir not in ('.', '..', '/'):
        os.makedirs(musldefs_dir, exist_ok=True)
    os.makedirs(types_dir, exist_ok=True)

    fix_types(arch_alltypes, alltypes, musldefs_h, alltypes_h, types_dir)

if __name__ == '__main__':
    main(sys.argv)
