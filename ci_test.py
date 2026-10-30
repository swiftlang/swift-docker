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
import argparse


def run_command(cmd, log_file=None):
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    print("Running: {}".format(shlex.join(cmd)))
    sys.stdout.flush()
    if log_file:
        file = open(log_file, "w")
    else:
        file = None
    try:
        p = subprocess.Popen(cmd, stdout=file, stderr=file)
        (output, err) = p.communicate()
        return p.wait()
    finally:
        # Windows does not allow renaming files that are still open.
        if file:
            file.close()


def is_windows_dockerfile(filename, windows_version):
    components = [c.lower() for c in filename.split("/")]
    if "windows" not in components:
        return False
    # Smoke test images require build arguments and local build context
    # (installer and entry point) that are not available in CI.
    if "smoketest" in components:
        return False
    # Windows containers using process isolation must match the host OS
    # version, so only build the images for the runner's Windows version.
    return windows_version.lower() in components


def get_dockerfiles(windows_version=None):
    dockerfiles = []
    GITHUB_API_URL = "https://api.github.com"
    response = urllib.request.urlopen("{}/repos/{}/pulls/{}/files".format(GITHUB_API_URL,
                                                                   os.environ['ghprbGhRepository'],
                                                                   os.environ['ghprbPullId']))
    data = json.load(response)

    for file_info in data:
        filename = file_info['filename']
        print(filename)
        if file_info['status'] == 'removed':
            continue
        if "Dockerfile" not in filename:
            continue
        if windows_version:
            if is_windows_dockerfile(filename, windows_version):
                dockerfiles.append(filename)
        elif not "windows" in filename:
            dockerfiles.append(filename)
    return dockerfiles


def print_results(results):
    sorted(results.items(), key=lambda x: x[1])
    print("=======================")
    for dockerfile in results:
        print("{}: {}".format(dockerfile, results[dockerfile]))
    print("=======================")


def parse_args():
    parser = argparse.ArgumentParser(description="Build the Dockerfiles changed in a pull request.")
    parser.add_argument("--windows", metavar="VERSION",
                        help="build the Windows Dockerfiles for the given Windows version "
                             "(e.g. LTSC2022) instead of the Linux Dockerfiles")
    return parser.parse_args()


def main():
    args = parse_args()
    print("--- Running Docker Tests ---")
    results = {}
    suite_status = True
    dockerfiles = get_dockerfiles(args.windows)
    root_dir = os.path.dirname(os.path.realpath(__file__))
    for dockerfile in dockerfiles:
        # Make sure everything is relative
        dockerfile = os.path.relpath(os.path.realpath(dockerfile), root_dir)
        # Use forward slashes on Windows too, so that the image and log
        # file names below are derived the same way on every platform.
        dockerfile = dockerfile.replace(os.sep, "/")

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
            # Show the end of the build log so failures are visible in the
            # CI output without downloading the log artifacts.
            with open(log_file, errors="replace") as file:
                print("".join(file.readlines()[-100:]))
        else:
            results[dockerfile] = "PASSED"

        os.replace(log_file, results[dockerfile] + log_file)
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
