fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### run_unit_tests

```sh
[bundle exec] fastlane run_unit_tests
```

Run unit tests

### build_firebase_staging

```sh
[bundle exec] fastlane build_firebase_staging
```

Build and distribute Staging build to Firebase

### build_firebase_production

```sh
[bundle exec] fastlane build_firebase_production
```

Build and distribute Staging build to Firebase

### run_danger

```sh
[bundle exec] fastlane run_danger
```

Run Danger

### register_devices_and_update

```sh
[bundle exec] fastlane register_devices_and_update
```

Register new devices and update certificates and provisioning profile

### certificates

```sh
[bundle exec] fastlane certificates
```

Refresh provisioning profiles

### upload_symbols_to_firebase

```sh
[bundle exec] fastlane upload_symbols_to_firebase
```

Upload symbols to firebase

### ci_release_staging

```sh
[bundle exec] fastlane ci_release_staging
```

Build and upload staging to Firebase

### bump_version_and_build_number_on_release_or_hotfix

```sh
[bundle exec] fastlane bump_version_and_build_number_on_release_or_hotfix
```

Bump version and build nubmer on release branch

### git_add_build_tag

```sh
[bundle exec] fastlane git_add_build_tag
```

git add build tag

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
