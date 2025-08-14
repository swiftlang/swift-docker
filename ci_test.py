#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ci_test - Build all Dockerfiles -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2024 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors


from __future__ import absolute_import, print_function, unicode_literals

import urllib.request
import json
import subprocess
import shlex
import sys
import os


def run_command(cmd, log_file=None):
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    print("Running: {}".format(shlex.join(cmd)))
    sys.stdout.flush()
    if log_file:
        file = open(log_file, "w")
    else:
        file = None
    p = subprocess.Popen(cmd, stdout=file, stderr=file)

    (output, err) = p.communicate()
    return p.wait()


def get_dockerfiles():
    dockerfiles = []
    GITHUB_API_URL = "https://api.github.com"
    response = urllib.request.urlopen("{}/repos/{}/pulls/{}/files".format(GITHUB_API_URL,
                                                                   os.environ['ghprbGhRepository'],
                                                                   os.environ['ghprbPullId']))
    data = json.load(response)

    for file_info in data:
        filename = file_info['filename']
        print(filename)
        if "Dockerfile" in filename and not "windows" in filename:
            dockerfiles.append(filename)
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
    root_dir = os.path.dirname(os.path.realpath(__file__))
    for dockerfile in dockerfiles:
        # Make sure everything is relative
        dockerfile = os.path.relpath(os.path.realpath(dockerfile), root_dir)

        docker_dir = "."

        print("Testing {}".format(dockerfile))
        sys.stdout.flush()
        image_name = dockerfile.replace("/", "_").replace("-", "_").lower()
        log_file = f'{dockerfile.replace("/", "_")}.log'
        cmd = [
            'docker', 'build', '--no-cache=true',
            '-f', dockerfile,
            '-t', image_name,
            docker_dir
        ]
        if "buildx" in dockerfile:
            # if "buildx" is part of the path, we want to use the new buildx build system and build
            # for both amd64 and arm64.
            run_command("docker buildx create --use", log_file=log_file)
            run_command("docker buildx inspect --bootstrap", log_file=log_file)

            cmd = [
                'docker', 'buildx', 'build',
                '--platform', 'linux/arm64,linux/amd64',
                '--no-cache=true',
                '-f', dockerfile,
                '-t', image_name,
                docker_dir
            ]
            clean_command = f"docker buildx prune -af"
        else:
            clean_command = f"docker image rm {image_name}"

        status = run_command(cmd, log_file=log_file)
        results[dockerfile] = status
        if status != 0:
            suite_status = False
            results[dockerfile] = "FAILED"
        else:
            results[dockerfile] = "PASSED"

        cmd = [
            'mv', log_file, results[dockerfile] + log_file
        ]
        run_command(cmd)
        print("[{}] - {}".format(results[dockerfile], dockerfile))
        sys.stdout.flush()
        run_command(clean_command)
    run_command("docker image prune -f")

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
