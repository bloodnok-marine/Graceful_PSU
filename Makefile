# ----------
#  Makefile
# 
#       Makefile for GracefulPSU
# 
#       Copyright (c) 2024 Marc Munro
# 	License: GPL-3.0
#  
#  ----------
#

# Note that this directory hierarchy does not use recursive make
# (see the article "Recursive Make Considered Harmful for a
# rationale).  Instead, this is the sole target-defining Makefile.  In
# subdirectories you may find links to GNUmakefile.  If make is run in
# such a directory it will change directory to the parent directory
# and run the same make command, meaning that this makefile will be
# used, even from subdirectories.  This allows builds to be done from
# any directory, with proper tracking of where the build takes place
# for tools such as emacs' compile and next-error.
#

# Do not use make's built-in rules
# (this improves performance and avoids hard-to-debug behaviour).
#
MAKEFLAGS += -r



################################################################
# Definitions
#

MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR = $(dir $(MAKEFILE))
ALL_DIRS = docs kicad
PANDOC = /usr/bin/pandoc

PCBFILE_SUFFICES = B_Cu.gbr B_Mask.gbr B_Paste.gbr B_Silkscreen.gbr \
		   Edge_Cuts.gbr F_Cu.gbr F_Mask.gbr F_Paste.gbr \
		   F_Silkscreen.gbr job.gbrjob NPTH.drl \
		   NPTH-drl_map.gbr PTH.drl PTH-drl_map.gbr

KICAD_PROJECTFILE = $(wildcard $(PROJECT_DIR)/kicad/*.kicad_pro)
KICAD_PROJECTNAME = $(subst .kicad_pro,,$(notdir $(KICAD_PROJECTFILE)))
KICAD_PCBFILES = $(PCBFILE_SUFFICES:%=kicad/pcbfiles/$(KICAD_PROJECTNAME)-%)
KICAD_SCHEMATIC_FILE = kicad/$(KICAD_PROJECTNAME).kicad_sch

###########
# Verbosity control.  Define VERBOSE on the command line to show the
# full compilation, etc commands.  If VERBOSE is defined $(FEEDBACK)
# will do nothing and $(AT) will have no effect, otherwise $(FEEDBACK)
# will perform an echo and $(AT) will make the command that follows it
# execute quietly.
# FEEDBACK2 may be used in multi-line shell commands where part of the
# command can usefully provide feedback.
#

ifdef VERBOSE
    FEEDBACK = @true
    FEEDBACK2 = true
    VERBOSEP = VERBOSE=y
    AT =
else
    FEEDBACK = @echo " "
    FEEDBACK2 = echo " "
    AT = @
endif


################################################################
# Default target
#

.PHONY: default
default: help


################################################################
# docs targets
#

.PHONY: docs
docs: docs/psu.html docs/README.html

# Create html from markdown.  This enables us to test the formatting of
# markdown files.
#
%.html: %.md
	$(PANDOC) --shift-heading-level-by=-1 $*.md \
		--standalone --to=html >$*.html


################################################################
# check targets
# These are used to cause make to fail with a helpful message if some
# condition is not met.  They are primarily used to ensure that
# everything is ready prior to releasing to github.
#

.PHONY: check check_schematic check_pcbfiles check_git_status \
	clear_schematic_sentinel clear_pcbfiles_sentinel \
	check_revision check_committed

SCHEMATIC_HELP = \
"Create a new circuit schematic pdf using the \"Plot\" option from the" \
"\\n\"File\" menu of the Schematic Editor, and selecting the pdf output" \
"\\n\type.  Close the Schematic Editor without saving."

PCBFILES_HELP = \
"Update pcbfiles from the PCB Editor by selecting \"Fabrication Outputs\"" \
"\\nand then \Gerbers\" from the \"File\" menu.  Press \"Generate Drill" \
"\\nFiles\" and then \"Generate Map File\", \"Generate Drill File\" and" \
"\\n\"Close\".  Then press \"Plot\".  Close the PCB Editor without saving."

ifdef HELP
   SHOW_SCHEMATIC_HELP = echo "$(SCHEMATIC_HELP)"
   SHOW_PCBFILES_HELP = echo "$(PCBFILES_HELP)"
else
   SHOW_SCHEMATIC_HELP = true
   SHOW_PCBFILES_HELP = true
endif

# Check
# Check various conditions to check the completeness of the project
# for releasing to github, etc.
#
# The files .noschematic, xxx are used as sentinels to identify the
# failure of a given check.  This is done so that all checks can be
# performed before reporting an error status.
# 
check: check_schematic check_pcbfiles check_revision check_committed
	@if [ -f .schematic_sentinel ]; then $(SHOW_SCHEMATIC_HELP); fi
	@if [ -f .pcbfiles_sentinel ]; then $(SHOW_PCBFILES_HELP); fi
	@[ ! -f .schematic_sentinel ]
	@[ ! -f .pcbfiles_sentinel ]

# check_schematic
# Check that there is an up to date pdf schematic.
#
check_schematic: kicad/GracefulPSU.pdf

kicad/GracefulPSU.pdf: kicad/GracefulPSU.kicad_sch \
	| clear_schematic_sentinel
	@echo "  The circuit schematic $@ is not up to date" 1>&2
	@touch .schematic_sentinel

clear_schematic_sentinel:
	@rm -f .schematic_sentinel >/dev/null || true

# check_pcbfiles
# Check that gerber, drill files, etc are up to date with the
# schematic and pcb file.
#
check_pcbfiles: $(KICAD_PCBFILES)
$(KICAD_PCBFILES): kicad/GracefulPSU.kicad_sch \
		   kicad/GracefulPSU.kicad_pcb \
	| clear_pcbfiles_sentinel
	@echo "  $@ is not up to date with pcb file" 1>&2
	@touch .pcbfiles_sentinel

clear_pcbfiles_sentinel:
	@rm -f .pcbfiles_sentinel >/dev/null || true

# check_revision
# Check that the schematic version matches that in the documentation.
# We Assume with this check that if the date is correct, the revision
# number will be as well.  This is just to simplify the code below.
#
DATE_REGEXP = [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]
check_revision:
	@date=`grep "current version" docs/psu.md | \
	    sed -e 's/.*\($(DATE_REGEXP)\).*/\1/'`; \
	if grep -q "(date.*$${date}" "$(KICAD_SCHEMATIC_FILE)"; then \
	    true; \
	else \
	    echo "\n  Date/revision in psu.md does not match"\
		 "schematic\n" 1>&2; \
	    exit 2; \
	fi

# Ensure that we are on the master branch and have committed it locally.
check_committed:
	@(git status | grep -q 'On branch master') && \
	(git status | grep -q 'nothing to commit') || \
	(echo "\n  Master branch not committed\n" 1>&2; exit 2)


################################################################
# Clean (and tidy) targets
#

.PHONY: tidy do_tidy clean 
garbage := \\\#*  .\\\#*  *~ 
ALL_GARBAGE = $(garbage) \
		$(foreach dir, $(ALL_DIRS), $(garbage:%=$(dir)/%))

# Tidy is a clean-up target that just removes garbage files from
# everywhere.
#
tidy:	do_tidy
	@echo Done

# Do_tidy does the hard work for tidy without issuing the "Done"
# message after completion.
#
do_tidy:
	@echo Removing garbage...
	$(AT) rm -f $(ALL_GARBAGE)

clean:  do_tidy
	@echo Removing generated files...
	$(AT) rm -rf docs/*html 2>/dev/null || true
	@echo Done


################################################################
# Provide some helpful clues for developers
#
.PHONY: help
help:
	@echo "\nMajor targets of bgpio's Makefile:"
	@echo "  check       - ensure everything is ready for push to github"
	@echo "  clean       - remove all generated, backup and target files"
	@echo "  docs        - build doxygen documentation (into docs/html)"
	@echo "  help        - list major makefile targets"
	@echo "  pages       - release docs to github-pages (alias for gitdocs)"
	@echo "  tidy        - remove all garbage files (such as emacs backups)"
	@echo "\nTo increase feedback, define VERBOSE=y on the command line."
	@echo "\nFor help fixing errors from the check target, define"
	@echo "HELP=y on the command line."
	@echo "\nFor more information read this Makefile ($(MAKEFILE))."
