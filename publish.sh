#!/bin/bash
# Push to pypi, tag and push to bitbucket

ver=$(python setup.py --version)

# Fail on 1'st error
set -e
set -x

# Make sure we have made the tag
if git rev-parse $ver >/dev/null 2>&1; then
    true # Tag found
else
    echo "$ver git tag not found. Make sure you run 'make tag' first"
    exit 1
fi

OSes="win_amd64
macosx_10_13_x86_64
manylinux1_x86_64"

PyVers="27
34
35
36
37"

for os in $OSes; do
    for pyver in $PyVers; do
        if [[ ${os} == "win_amd64" && ${pyver} == "34" ]]; then
            true  # Windows doesn't build on 3.4 due to some AppVeyor issues
        else
            wget -q --directory-prefix=dist/ https://github.com/fastavro/fastavro/releases/download/${ver}/fastavro-${ver}-cp${pyver}-cp${pyver}m-${os}.whl
        fi
    done
done

make fresh
FASTAVRO_USE_CYTHON=1 python setup.py sdist

twine upload dist/fastavro-${ver}.tar.gz
twine upload dist/fastavro-${ver}*.whl

# print sha so we can use it in conda-forge recipe
sha256sum dist/fastavro-${ver}.tar.gz
rm -fr build dist/* fastavro.egg-info/
