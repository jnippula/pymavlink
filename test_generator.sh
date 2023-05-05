#!/bin/bash

# This requires the python future library
# On MS windows, cygwin usually does not provide that.
# The workaround is then to issue on a cygwin prompt:
#   easy_install-2.7 pip
#   pip install future

set -e
set -x

test -z "$MDEF" && MDEF="../message_definitions"

# MAVLINK_DIALECT=ardupilotmega python setup.py clean build install --user

tools/mavgen.py --lang C $MDEF/v1.0/all.xml -o generator/C/include_v1.0 --wire-protocol=1.0
tools/mavgen.py --lang C $MDEF/v1.0/all.xml -o generator/C/include_v2.0 --wire-protocol=2.0
tools/mavgen.py --lang C++11 $MDEF/v1.0/all.xml -o generator/CPP11/include_v2.0 --wire-protocol=2.0

pushd generator/C/test/posix

make ENDIANESS=MAVLINK_LITTLE_ENDIAN clean testmav1.0_ardupilotmega testmav2.0_ardupilotmega
# these test tools emit the test packet as hexadecimal and human-readable, other tools consume it as a cross-reference, we ignore the hex here.
./testmav1.0_ardupilotmega | egrep -v '(^fe|^fd)'
./testmav2.0_ardupilotmega | egrep -v '(^fe|^fd)'

make ENDIANESS=MAVLINK_BIG_ENDIAN clean testmav1.0_ardupilotmega testmav2.0_ardupilotmega
# these test tools emit the test packet as hexadecimal and human-readable, other tools consume it as a cross-reference, we ignore the hex here.
./testmav1.0_ardupilotmega | egrep -v '(^fe|^fd)'
./testmav2.0_ardupilotmega | egrep -v '(^fe|^fd)'

popd

pushd generator/CPP11/test/posix
make clean all
popd
