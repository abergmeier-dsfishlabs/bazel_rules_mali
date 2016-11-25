# Mali Rules for Bazel (αlpha)

## Setup

* Decide on the name of your package, eg. `github.com/joe/project`
* Add the following to your WORKSPACE file:

    ```bzl
    git_repository(
        name = "com_arm_mali",
        remote = "https://github.com/DeepSilverFishlabs/bazel_rules_mali.git",
    )
    load("@com_arm_mali//mali:def.bzl", "tct_repository")

    ```
