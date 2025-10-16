<div align="center">

# asdf-pants [![Build](https://github.com/michael/asdf-pants/actions/workflows/build.yml/badge.svg)](https://github.com/michael/asdf-pants/actions/workflows/build.yml) [![Lint](https://github.com/michael/asdf-pants/actions/workflows/lint.yml/badge.svg)](https://github.com/michael/asdf-pants/actions/workflows/lint.yml)

[pants](https://www.pantsbuild.org) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add pants
# or
asdf plugin add pants https://github.com/michael/asdf-pants.git
```

pants:

```shell
# Show all installable versions
asdf list-all pants

# Install specific version
asdf install pants latest

# Set a version globally (on your ~/.tool-versions file)
asdf global pants latest

# Now pants commands are available
pants --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/michael/asdf-pants/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Michael](https://github.com/michael/)
