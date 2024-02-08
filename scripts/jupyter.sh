#!/usr/bin/env bash
# Copyright (c) 2024, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.

set -e

cd /data

[[ -r /etc/JARVICE/jobenv.sh ]] && . /etc/JARVICE/jobenv.sh
[[ -r /etc/JARVICE/jobinfo.sh ]] && . /etc/JARVICE/jobinfo.sh

# parse command line
REQUIREMENTS=""
BASEURL=""
MODE="$1"
while [[ -n "$1" ]]; do
    case "$1" in
    -mode)
        shift
        MODE="$1"
        ;;
    -r)
        shift
        REQUIREMENTS="$1"
        python3.11 -m pip install --user -r $REQUIREMENTS
        ;;
    -u)
        shift
        BASEURL="$1"
        ;;
    *)
        ;;
    esac
    shift
done

# default internal Jupyter port is 5902 unless overridden
PORTNUM=${JARVICE_SERVICE_PORT:-5902}
[[ -z "${PORT}" ]] && PORT=$PORTNUM

# default base_url to '/'
[[ -z "${BASEURL}" ]] && BASEURL='/'

# Temporary check for the PS1 variable for terminal
if [[ -z "${PS1}" ]]; then
    export PS1="[\u@\h:\w]$ "
    echo "export PS1=\"[\u@\h:\w]\$ \"" >> $HOME/.bashrc
fi

exec python3.11 -m jupyter ${MODE} --ip=0.0.0.0 --no-browser --port=${PORT} \
    --NotebookApp.token=$(cat /etc/JARVICE/random128.txt | cut -c 1-64) \
    --NotebookApp.base_url=${BASEURL}
