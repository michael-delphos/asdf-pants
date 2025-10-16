# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: adapt this
asdf plugin test pants https://github.com/michael/asdf-pants.git "pants --version"
```

Tests are automatically run in GitHub Actions on push and PR.
