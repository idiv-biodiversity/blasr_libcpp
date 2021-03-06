SHELL          = bash
G_BUILDOS_CMD := bash -c 'set -e; set -o pipefail; id=$$(lsb_release -si | tr "[:upper:]" "[:lower:]"); rel=$$(lsb_release -sr); case $$id in ubuntu) printf "$$id-%04d\n" $${rel/./};; centos) echo "$$id-$${rel%%.*}";; *) echo "$$id-$$rel";; esac' 2>/dev/null
OS_STRING     ?= $(shell $(G_BUILDOS_CMD))

ifeq ($(origin PREBUILT), undefined)
PREBUILT := $(shell cd ../../../../prebuilt.out 2>/dev/null && pwd || echo -n notfound)
endif

THIRD_PARTY_PREFIX ?= ../..

ifneq ($(COMMON_NO_THIRD_PARTY_REQD),true)
    #
    # Definitions common to all make files for library code.
    # All paths are relative from inside the subdirectories, not this file
    #

    # git layout vs p4 layout automagic
    THIRD_PARTY ?= $(shell cd $(abspath $(THIRD_PARTY_PREFIX)/third-party) 2>/dev/null && pwd || echo -n notfound)
    ifeq ($(THIRD_PARTY), notfound)
	THIRD_PARTY := $(shell cd $(abspath $(THIRD_PARTY_PREFIX)/../third-party/cpp) 2>/dev/null && pwd || echo -n notfound)
    endif

    # handle HDF5_INC HDF5_LIB
    ifeq ($(origin HDF5_INC), undefined)
	HDF5_INC := $(shell cd $(PREBUILT)/hdf5/hdf5-1.8.12/$(OS_STRING)/include 2>/dev/null && pwd || echo -n notfound)
    else
	HDF5_INC := $(shell cd $(HDF5_INC) 2>/dev/null && pwd || echo -n notfound)
    endif
    ifeq ($(HDF5_INC), notfound)
	ifeq ($(THIRD_PARTY), notfound)
                $(error cannot find third-party libraries!)
	endif
	HDF5_INC := $(shell cd $(THIRD_PARTY)/hdf5/include 2>/dev/null && pwd || echo -n notfound)
    endif
    ifeq ($(origin HDF5_LIB), undefined)
	HDF5_LIB := $(shell cd $(PREBUILT)/hdf5/hdf5-1.8.12/$(OS_STRING)/lib 2>/dev/null && pwd || echo -n notfound)
    else
	HDF5_LIB := $(shell cd $(HDF5_LIB) 2>/dev/null && pwd || echo -n notfound)
    endif
    ifeq ($(HDF5_LIB), notfound)
	ifeq ($(THIRD_PARTY), notfound)
                $(error cannot find third-party libraries!)
	endif
	HDF5_LIB := $(shell cd $(THIRD_PARTY)/hdf5/lib 2>/dev/null && pwd || echo -n notfound)
    endif

    # handle ZLIB_ROOT
    ifeq ($(origin ZLIB_ROOT), undefined)
	ZLIB_ROOT := $(shell cd $(PREBUILT)/zlib/zlib-1.2.5/$(OS_STRING) 2>/dev/null && pwd || echo -n notfound)
    else
	ZLIB_ROOT := $(shell cd $(ZLIB_ROOT) 2>/dev/null && pwd || echo -n notfound)
    endif

    ifeq ($(ZLIB_ROOT), notfound)
	# we don't need a backup ZLIB_ROOT here, because almost everybody has one in their paths
    endif
endif

# handle BOOST
ifeq ($(origin BOOST_INCLUDE), undefined)
ifeq ($(origin BOOST_ROOT), undefined)
BOOST_INCLUDE := $(PREBUILT)/boost/boost_1_55_0
else
BOOST_INCLUDE := $(BOOST_ROOT)
endif
endif

# handle PBBAM
ifeq ($(origin PBBAM), undefined)
PBBAM := $(shell cd $(THIRD_PARTY_PREFIX)/../staging/PostPrimary/pbbam 2>/dev/null && pwd || echo -n notfound)
endif

# magic for non-verbose builds
V ?= 0

CXX_0 = @echo "  CXX	$@"; $(CXX)
CXX_1 = $(CXX)
CXX_pp = $(CXX_$(V))

AR_0 = @echo "  AR	$@"; $(AR)
AR_1 = $(AR)
AR_pp = $(AR_$(V))

ARFLAGS := rc
