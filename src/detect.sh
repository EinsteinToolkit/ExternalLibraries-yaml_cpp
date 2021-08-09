#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors

. $CCTK_HOME/lib/make/bash_utils.sh

# Take care of requests to build the library in any case
YAML_CPP_DIR_INPUT=$YAML_CPP_DIR
if [ "$(echo "${YAML_CPP_DIR}" | tr '[a-z]' '[A-Z]')" = 'BUILD' ]; then
    YAML_CPP_BUILD=1
    YAML_CPP_DIR=
else
    YAML_CPP_BUILD=
fi

# default value for FORTRAN support
if [ -z "$YAML_CPP_ENABLE_FORTRAN" ] ; then
    YAML_CPP_ENABLE_FORTRAN="OFF"
fi

################################################################################
# Decide which libraries to link with
################################################################################

# Set up names of the libraries based on configuration variables. Also
# assign default values to variables.
# Try to find the library if build isn't explicitly requested
if [ -z "${YAML_CPP_BUILD}" -a -z "${YAML_CPP_INC_DIRS}" -a -z "${YAML_CPP_LIB_DIRS}" -a -z "${YAML_CPP_LIBS}" ]; then
    find_lib YAML_CPP amrex 1 1.0 "amrex" "yaml-cpp.H" "$YAML_CPP_DIR"
fi

THORN=yaml-cpp

# configure library if build was requested or is needed (no usable
# library found)
if [ -n "$YAML_CPP_BUILD" -o -z "${YAML_CPP_DIR}" ]; then
    echo "BEGIN MESSAGE"
    echo "Using bundled yaml-cpp..."
    echo "END MESSAGE"
    YAML_CPP_BUILD=1

    check_tools "tar patch"
    
    # Set locations
    BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
    if [ -z "${YAML_CPP_INSTALL_DIR}" ]; then
        INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
    else
        echo "BEGIN MESSAGE"
        echo "Installing yaml-cpp into ${YAML_CPP_INSTALL_DIR}"
        echo "END MESSAGE"
        INSTALL_DIR=${YAML_CPP_INSTALL_DIR}
    fi
    YAML_CPP_DIR=${INSTALL_DIR}
    # Fortran modules may be located in the lib directory
    YAML_CPP_INC_DIRS="${YAML_CPP_DIR}/include ${YAML_CPP_DIR}/lib"
    YAML_CPP_LIB_DIRS="${YAML_CPP_DIR}/lib"
    YAML_CPP_LIBS="amrex"
else
    DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
    if [ ! -e ${DONE_FILE} ]; then
        mkdir ${SCRATCH_BUILD}/done 2> /dev/null || true
        date > ${DONE_FILE}
    fi
fi

if [ -n "$YAML_CPP_DIR" ]; then
    : ${YAML_CPP_RAW_LIB_DIRS:="$YAML_CPP_LIB_DIRS"}
    # Fortran modules may be located in the lib directory
    YAML_CPP_INC_DIRS="$YAML_CPP_RAW_LIB_DIRS $YAML_CPP_INC_DIRS"
    # We need the un-scrubbed inc dirs to look for a header file below.
    : ${YAML_CPP_RAW_INC_DIRS:="$YAML_CPP_INC_DIRS"}
else
    echo 'BEGIN ERROR'
    echo 'ERROR in yaml-cpp configuration: Could neither find nor build library.'
    echo 'END ERROR'
    exit 1
fi

################################################################################
# Check for additional libraries
################################################################################


################################################################################
# Configure Cactus
################################################################################

# Pass configuration options to build script
echo "BEGIN MAKE_DEFINITION"
echo "YAML_CPP_BUILD          = ${YAML_CPP_BUILD}"
echo "YAML_CPP_ENABLE_FORTRAN = ${YAML_CPP_ENABLE_FORTRAN}"
echo "YAML_CPP_INSTALL_DIR    = ${YAML_CPP_INSTALL_DIR}"
echo "END MAKE_DEFINITION"

# Pass options to Cactus
echo "BEGIN MAKE_DEFINITION"
echo "YAML_CPP_DIR            = ${YAML_CPP_DIR}"
echo "YAML_CPP_ENABLE_FORTRAN = ${YAML_CPP_ENABLE_FORTRAN}"
echo "YAML_CPP_INC_DIRS       = ${YAML_CPP_INC_DIRS}"
echo "YAML_CPP_LIB_DIRS       = ${YAML_CPP_LIB_DIRS}"
echo "YAML_CPP_LIBS           = ${YAML_CPP_LIBS}"
echo "END MAKE_DEFINITION"

echo 'INCLUDE_DIRECTORY $(YAML_CPP_INC_DIRS)'
echo 'LIBRARY_DIRECTORY $(YAML_CPP_LIB_DIRS)'
echo 'LIBRARY           $(YAML_CPP_LIBS)'
