# Smallstache.sh

[![Quality check status](https://github.com/macie/smallstache.sh/actions/workflows/check.yml/badge.svg)](https://github.com/macie/smallstache.sh/actions/workflows/check.yml)
[![License](https://img.shields.io/github/license/macie/smallstache.sh)](https://tldrlegal.com/license/mit-license)

A commandline, POSIX-compliant [logic-less template engine](https://en.wikipedia.org/wiki/Web_template_system)
similar to [Mustache](https://mustache.github.io/)/[Handlebars](http://handlebarsjs.com/).

## Usage

`smallstache` takes template from commandline argument and key-value data from stdin:

```bash
$ echo 'Hello {{ something }}!' >template
$ echo 'something=World' | smallstache template
Hello World!
```

It can use any source of standard unix key-value data format:

```bash
$ echo 'Your PATH variable: {{ PATH }}' >template
$ set | smallstache template
Your PATH variable: /bin:/usr/bin
```

## Installation

>The instruction is for Linux. On different OSes, you may need to use different
>commands

1. Download [latest stable release from GitHub](https://github.com/macie/smallstache.sh/releases/latest):

    ```bash
    wget https://github.com/macie/smallstache.sh/releases/latest/download/smallstache
    ```

2. (OPTIONAL) Verify downloading:

    ```bash
    wget https://github.com/macie/smallstache.sh/releases/latest/download/smallstache.sha256sum
    sha256sum -c smallstache.sha256sum
    ```

3. Set execute permission:

    ```bash
    chmod +x smallstache
    ```

4. Move to directory from `PATH` environment variable:

    ```bash
    mv smallstache /usr/local/bin/
    ```

### Development version

```bash
git clone git@github.com:macie/smallstache.sh.git
cd smallstache.sh
make install
```

## Development

Use `make` (GNU or BSD):

- `make` - run checks
- `make test` - run test
- `make check` - perform static code analysis
- `make install` - install in `/usr/local/bin`
- `make dist` - prepare for distributing
- `make clean` - remove distributed artifacts
- `make cli-release` - tag latest commit as a new release
- `make info` - print system info (useful for debugging).

### Versioning

`smallstache` is versioned according to the scheme `YY.0M.MICRO` ([calendar versioning](https://calver.org/)). Releases are tagged in Git.

## Known bugs

### Argument list too long

`smallstache` handles limited length of key-value pairs. When you exceed
the limit, you will see an error such as:

```
smallstache[41]: sed: Argument list too long
```

As a workaround, fill template in parts with following steps:

```bash
# save key-value pairs to a few parts
set >data
split -l 2000 -a 5 data data_part_

# fill the template
cp template result
for part in data_part_*; do
	smallstache result <"$part" >partially_filled
	cp partially_filled result
done

# see the result
cat result
```

For more information, see [ARG_MAX, maximum length of arguments for a new process](https://www.in-ulm.de/~mascheck/various/argmax/).

## License

[MIT](./LICENSE) ([explanation in simple words](https://tldrlegal.com/license/mit-license))
