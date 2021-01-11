SHELL = /bin/bash -eu
.DELETE_ON_ERROR:
.SECONDARY:
.SUFFIXES:

EXT_SUFFIX := $(shell python -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX"))')

SONAME = hfst_optimized_lookup/_hfstol$(EXT_SUFFIX)

.PHONY: test
test: all
	pytest -s --doctest-glob=README.md

.PHONY: all
all: $(SONAME) crk-descriptive-analyzer.hfstol hfst-optimized-lookup

%.hfstol:
	wget "https://github.com/UAlbertaALTLab/cree-intelligent-dictionary/raw/master/CreeDictionary/res/fst/$@"

# If any files are out of date, let setup.py handle it
$(SONAME): \
    setup.py \
    hfst_optimized_lookup/_hfst_optimized_lookup.pyx \
    hfst_optimized_lookup/hfst-optimized-lookup.cc \
    hfst_optimized_lookup/hfst-optimized-lookup.h \

	pipenv run python setup.py build_ext --inplace

# Make an executable out of our code, so that we can test if it still behaves
# on the command line as hfst-optimized-lookup should
hfst-optimized-lookup: \
    hfst_optimized_lookup/hfst-optimized-lookup.cc \
    hfst_optimized_lookup/hfst-optimized-lookup.h \

	g++ -W -Wall -Werror -o $@ $<

clean::
	rm -f hfst-optimized-lookup

clean::
	rm -f $(SONAME) hfst_optimized_lookup/_hfst_optimized_lookup.cpp
	rm -rf build
