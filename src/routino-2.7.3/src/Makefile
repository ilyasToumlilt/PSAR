# Source code Makefile
#
# Part of the Routino routing software.
#
# This file Copyright 2008-2014 Andrew M. Bishop
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# All configuration is in the top-level Makefile.conf

include ../Makefile.conf

# Debugging options

#CFLAGS+=-O0 -g
#CFLAGS+=-pg
#CFLAGS+=-fprofile-arcs -ftest-coverage

#LDFLAGS+=-pg -static
#LDFLAGS+=-fprofile-arcs -ftest-coverage

# Sub-directories and sub-makefiles

SUBFILES=$(wildcard */Makefile)
SUBDIRS=$(foreach f,$(SUBFILES),$(dir $f))

# Compilation targets

C=$(wildcard *.c)
D=$(wildcard .deps/*.d)

EXE=router

########

all: all-local
	for dir in $(SUBDIRS); do \
	   ( cd $$dir && $(MAKE) $@ ); \
	done

all-local: $(EXE)

########

ROUTER_OBJ=router.o \
	   nodes.o segments.o ways.o relations.o types.o fakes.o \
	   optimiser.o output.o \
	   files.o logging.o profiles.o xmlparse.o \
	   results.o queue.o translations.o

router : $(ROUTER_OBJ)
	$(LD) $(ROUTER_OBJ) -o $@ $(LDFLAGS)

########

%.o : %.c
	@[ -d .deps ] || mkdir .deps
	$(CC) -c $(CFLAGS) -DSLIM=0 -DDATADIR=\"$(datadir)\" $< -o $@ -MMD -MP -MF $(addprefix .deps/,$(addsuffix .d,$(basename $@)))

########

test: test-local
	for dir in $(SUBDIRS); do \
	   ( cd $$dir && $(MAKE) $@ ); \
	done

test-local:

########

install: install-local
	for dir in $(SUBDIRS); do \
	   ( cd $$dir && $(MAKE) $@ ); \
	done

install-local: all-local
	@[ -d $(DESTDIR)$(bindir) ] || mkdir -p $(DESTDIR)$(bindir)
	@for file in $(EXE); do \
	    echo cp $$file $(DESTDIR)$(bindir) ;\
	    cp -f $$file $(DESTDIR)$(bindir) ;\
	 done

########

clean: clean-local
	for dir in $(SUBDIRS); do \
	   ( cd $$dir && $(MAKE) $@ ); \
	done

clean-local:
	rm -f *~
	rm -f *.o
	rm -f core
	rm -f *.gcda *.gcno *.gcov gmon.out

########

distclean: distclean-local
	for dir in $(SUBDIRS); do \
	   ( cd $$dir && $(MAKE) $@ ); \
	done

distclean-local: clean-local
	-rm -f $(EXE)
	-rm -f $(D)
	-rm -fr .deps

########

include $(D)

########

.PHONY:: all test install clean distclean

.PHONY:: all-local test-local install-local clean-local distclean-local
