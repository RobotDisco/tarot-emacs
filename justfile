# Emacs versions tested locally and in CI, via purcell/nix-emacs-ci.
# Include the latest patch version of each major version,  plus snapshot -- patch releases
# Attribute names use dashes for dots (25.1 -> 25-1);
# see https://github.com/purcell/nix-emacs-ci for the full list of builds.
versions := "26-3 27-2 28-2 29-4 30-2 snapshot"

default:
	@just --list

# Byte-compile the package under one Emacs version, failing on any warning.
compile version="30-2":
    nix run --accept-flake-config 'github:purcell/nix-emacs-ci#emacs-{{version}}' -- \
        -Q --batch -L . --eval '(setq byte-compile-error-on-warn t)' \
        -f batch-byte-compile tarot.el tarot-meanings.el tarot-test.el

# Run the ERT suite under one Emacs version, e.g. `just test 27-2`.
test version="30-2": (compile version)
    nix run --accept-flake-config 'github:purcell/nix-emacs-ci#emacs-{{version}}' -- \
        -Q --batch -L . -l tarot-test.el -f ert-run-tests-batch-and-exit

# Run the ERT suite under every version in the support matrix.
test-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for v in {{versions}}; do
        echo "=== Emacs $v ==="
        just test "$v"
    done

# Remove byte-compiled artifacts left behind by `compile`/`test`.
clean:
    rm -f *.elc
