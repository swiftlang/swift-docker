#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ci_test - Build all Dockerfiles -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2019 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors


from __future__ import absolute_import, print_function, unicode_literals

import subprocess
import sys
import os

def run_command(cmd, log_file=None):
    print("Running: {}".format(cmd))
    sys.stdout.flush()
    if log_file:
        file = open(log_file, "w")
        p = subprocess.Popen(cmd, shell=True, stdout=file, stderr=file)
    else:
        p = subprocess.Popen(cmd, shell=True)
      
    (output, err) = p.communicate()
    return p.wait()


def get_dockerfiles():
    dockerfiles = []
    docker_dir = os.path.dirname(os.path.realpath(__file__))
    for root, dirs, files in os.walk(docker_dir):
        for file in files:
            if file == "Dockerfile":
                 dockerfiles.append(root)
    dockerfiles.sort(reverse=True)
    return dockerfiles


def print_results(results):
    sorted(results.items(), key=lambda x: x[1])
    print("=======================")
    for dockerfile in results:
        print("{}: {}".format(dockerfile, results[dockerfile]))
    print("=======================")


def main():
    print("--- Running Docker Tests ---")
    results = {}
    suite_status = True
    dockerfiles = get_dockerfiles()
    for dockerfile in dockerfiles:
        docker_dir = os.path.dirname(os.path.realpath(__file__))
        print("Testing {}".format(dockerfile))
        sys.stdout.flush()
        log_file = dockerfile.replace(docker_dir,"").replace("/", "_")
        log_file = "{}.log".format(log_file)
        cmd = "docker build --no-cache=true {}".format(dockerfile)
        status = run_command(cmd, log_file)
        results[dockerfile] = status
        if status != 0:
            suite_status = False
            results[dockerfile] = "FAILED"
        else:
            results[dockerfile] = "PASSED"

        cmd = "mv {log} {results}{log}".format(log=log_file, results=results[dockerfile])
        run_command(cmd)
        print("[{}] - {}".format(results[dockerfile], dockerfile))
        sys.stdout.flush()

    for dockerfile in dockerfiles:
        if results[dockerfile] == "FAILED":
            print("[{}] - {}".format(results[dockerfile], dockerfile))

    if suite_status == False:
        sys.exit(1)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(1)
