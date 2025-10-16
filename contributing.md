# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test pants https://github.com/michael-delphos/asdf-pants.git "SCIE_BOOT=update pants --help"
```

Tests are automatically run in GitHub Actions on push and PR.
