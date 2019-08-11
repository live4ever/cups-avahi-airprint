#!/bin/sh
set -x
set -e

# See http://support.brother.com/g/s/id/linux/en/instruction_prn1a.html
# install libstdc++6 reuiqred by LPR and CPU wrapper

tmpfile=$(mktemp brother_lpr_found.XXXXXX)
trap "rm -f ${tmpfile}" INT TERM HUP EXIT
find . -type f -name '*cupswrapper*.deb' -printf '%f\n' | sort > ${tmpfile}

DRV_PKG=
while read -r cupswrapper ; do
	model=$(echo $cupswrapper|sed 's;cupswrapper.*;;')
	lpr=$(find . -type f -name "${model}lpr*.deb" -printf '%f\n')
	if [ -z "{lpr}" ]; then
		echo "Cann't find LPR driver for ${model} cupswrapper driver"
		exit 1
	fi
	echo "Adding cupswrapper LPR drivers for Brother ${model}"
	DRV_PKG=${DRV_PKG:+ ${lpr} ${cupswrapper}}
	DRV_PKG=${DRV_PKG:-${lpr} ${cupswrapper}}
done < ${tmpfile}

if [ ! -z "${DRV_PKG}" ]; then
	# install i386 architecture support 
	arch=$(dpkg --print-architecture)
	if [ "$arch" != "i386" ]; then 
		dpkg --add-architecture i386 && apt-get update && \
		apt-get install -y libstdc++6:i386 || exit 1
	fi
	dpkg -i ${DRV_PKG} || exit 1
fi

# remove all pre-installed driver
find /usr/local/Brother/Printer/ -name 'cupswrapperSetup_*' -exec {} -r  \;
