## Project Structure and Information

This is a community supported initiative to provide high quality Swift Docker images for production use.

## Working Group

@harisamin, @swizzlr and @khalian form the core working group for development of the images. This working group is entirely ad hoc and subject to coup at any time from interested parties.

## Relation to `official-images`
This is the source repository for the official Docker image of Swift. We are necessarily conservative in what we add to this repo for that reason.

However, the repo is also available as `swiftdocker/swift` on Docker Hub as an automated build. All older tags will remain there, and we may be able to provide pre-release builds here too.

## Support Commitments

### Docker Versions

We support the latest stable version of Docker only. This is currently 18.03.

### Swift Versions

- This project will only support the latest two major version numbers of Swift.
- This project will only support the latest minor version of the previous major version of Swift.
- This project will only support the latest two minor versions of the latest major version of Swift.
- This project will only support the latest patch version of any major version.

Currently, we are supporting `4.1`, `4.0.3` and `3.1.1`.

