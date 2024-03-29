#! /bin/bash

################################################################################
# Build
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors


    
# Define some environment variables
export CC=${EXTERNAL_CC:-${CC}}
export CXX=${EXTERNAL_CXX:-${CXX}}
export F90=${EXTERNAL_F90:-${F90}}
export LD=${EXTERNAL_LD:-${LD}}
export CFLAGS=${EXTERNAL_CFLAGS:-${CFLAGS}}
export CXXFLAGS=${EXTERNAL_CXXFLAGS:-${CXXFLAGS}}
export F90FLAGS=${EXTERNAL_F90FLAGS:-${F90FLAGS}}
export LDFLAGS=${EXTERNAL_LDFLAGS:-${LDFLAGS}}



# Set locations
THORN=yaml_cpp
NAME=yaml-cpp-0.6.3
SRCDIR="$(dirname $0)"
BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
if [ -z "${YAML_CPP_INSTALL_DIR}" ]; then
    INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
else
    echo "BEGIN MESSAGE"
    echo "Installing yaml-cpp into ${YAML_CPP_INSTALL_DIR}"
    echo "END MESSAGE"
    INSTALL_DIR=${YAML_CPP_INSTALL_DIR}
fi
DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
YAML_CPP_DIR=${INSTALL_DIR}

echo "yaml-cpp: Preparing directory structure..."
cd ${SCRATCH_BUILD}
mkdir build external done 2> /dev/null || true
rm -rf ${BUILD_DIR} ${INSTALL_DIR}
mkdir ${BUILD_DIR} ${INSTALL_DIR}

# Build core library
echo "yaml-cpp: Unpacking archive..."
pushd ${BUILD_DIR}
${TAR?} xf ${SRCDIR}/../dist/${NAME}.tar

echo "yaml-cpp: Configuring..."
cd ${NAME}

unset LIBS

mkdir build
cd build
${CMAKE_DIR:+${CMAKE_DIR}/bin/}cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DYAML_CPP_BUILD_TESTS=OFF ..

echo "yaml-cpp: Building..."
${MAKE}

echo "yaml-cpp: Installing..."
${MAKE} install
popd

echo "yaml-cpp: Cleaning up..."
rm -rf ${BUILD_DIR}

date > ${DONE_FILE}
echo "yaml-cpp: Done."
