# Contributing to `oidcc_conformance`

## Welcome!

We look forward to your contributions! Here are some examples how you can
contribute:

- [Report a bug](https://github.com/erlef/oidcc_conformance/issues/new?labels=bug&template=BUG.md)
- [Propose a new feature](https://github.com/erlef/oidcc_conformance/issues/new?labels=enhancement&template=FEATURE.md)
- [Send a pull request](https://github.com/erlef/oidcc_conformance/pulls)

## We have a Code of Conduct

Please note that this project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this
project you agree to abide by its terms.

## Any contributions you make will be under the Apache 2.0 License

When you submit code changes, your submissions are understood to be under the
same [Apache 2.0](https://github.com/erlef/oidcc_conformance/blob/main/LICENSE)
that covers the project. By contributing to this project, you agree that your
contributions will be licensed under its Apache 2.0 License.

## Write bug reports with detail, background, and sample code

In your bug report, please provide the following:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can.
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you
- tried that didn't work)

Please do not report a bug for a version of `oidcc` that is no longer
supported (`< 1.0.0`). Please do not report a bug if you are using a version of
Erlang or Elixir that is not supported by the version of `oidcc` you are using.

Please post code and output as text
([using proper markup](https://guides.github.com/features/mastering-markdown/)).
Do not post screenshots of code or output.

## Workflow for Pull Requests

1. Fork the repository.
2. Create your branch from `main` if you plan to implement new functionality or
   change existing code significantly; create your branch from the oldest branch
   that is affected by the bug if you plan to fix a bug.
3. Implement your change and add tests for it.
4. Ensure the test suite passes.
5. Ensure the code complies with our coding guidelines (see below).
6. Send that pull request!

Please make sure you have
[set up your user name and email address](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup)
for use with Git. Strings such as `silly nick name <root@localhost>` look really
stupid in the commit history of a project.

We encourage you to
[sign your Git commits with your GPG key](https://docs.github.com/en/github/authenticating-to-github/signing-commits).

Pull requests for new features must be based on the `main` branch.

We are trying to keep backwards compatibility breaks in `oidcc_conformance` to a
minimum. Please take this into account when proposing changes.

Due to time constraints, we are not always able to respond as quickly as we
would like. Please do not take delays personal and feel free to remind us if you
feel that we forgot to respond.

<!-- ## Coding Guidelines

This project comes with configured linters (located in `.credo.exs` in the
repository) that you can use to perform various checks:

```bash
$ mix credo
```

This project comes with configuration (located in `.formatter.exs` in the
repository) that you can use to (re)format your
source code for compliance with this project's coding guidelines:

```bash
$ mix format
```

This project uses `dialyzer` to perform static code checking. Run it to make
sure that your code is valid:

```bash
$ mix dialyzer
```

Please understand that we will not accept a pull request when its changes
violate this project's coding guidelines. -->

## Using `oidcc_conformance` from a Git checkout

The following commands can be used to perform the initial checkout of
`oidcc_conformance`:

```bash
$ git clone git@github.com:erlef/oidcc_conformance.git

$ cd oidcc_conformance
```

Install `oidcc_conformance`'s dependencies using [mix](https://hexdocs.pm/mix/Mix.html):

```bash
$ mix deps.get
```

<!-- ## Running `oidcc_conformance`'s test suite

After following the steps shown above, `oidcc_conformance`'s test suite is run like
this:

```bash
$ mix test
```
 -->
