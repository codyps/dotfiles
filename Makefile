all::

# Each file which needs a special operation on it is marked by a single character prefix
# % = recurse into directory
# _ = symlink
# ! = execute script with first arg as file
#
#
# TODO:
# - allow forced updating
# - avoid overwriting non-generated files
#   - add some content to the start of generated files?
#     - has to be custom for each file type
#   - use some file that lists the generated files?
#     - syncronization/regeneration issues

TYPES = subdir symlink script

# S = source
define DEF-SOURCE
s_subdir  += $(filter-out %~,$(wildcard $(1)/%*))
s_symlink += $(filter-out %~,$(wildcard $(1)/_*))
s_script  += $(filter-out %~,$(wildcard $(1)/!*))
$(foreach DIR,$(s_subdir),$(eval $(call DEF-SOURCE,$(DIR))))
endef

$(eval $(call DEF-SOURCE,.))

define GEN-PRINT
show-$(1) :
	@echo $$($(1))
endef

$(foreach t,$(TYPES),$(eval $(call GEN-PRINT,s_$(t))))
show-s :
	@echo :s_script:
	@$(MAKE) --no-print-directory show-s_script
	@echo :s_subdir:
	@$(MAKE) --no-print-directory show-s_subdir
	@echo :s_symlink:
	@$(MAKE) --no-print-directory show-s_symlink

# FIXME: Doesn't strip subdir's %!
# ex: "./%config/@somefile" -> "$(HOME)/%config/somefile"
to-d = $(abspath $(HOME)/$(dir $(2))$(patsubst $(1)%,%,$(notdir $(2))))

# XXX: to-s is untested!!!
strip-home = $(patsubst $(HOME)%,%,$(1))
to-s = $(dir $(call strip-home,$(1)))/$(2)$(notdir $(call strip-home,$(1)))

d_subdir  = $(foreach i,$(s_subdir),$(call to-d,\%,$(i)))
d_symlink = $(foreach i,$(s_symlink),$(call to-d,_,$(i)))
d_script  = $(foreach i,$(s_script),$(call to-d,!,$(i)))

$(foreach t,$(TYPES),$(eval $(call GEN-PRINT,d_$(t))))
show-d :
	@echo :d_script:
	@$(MAKE) --no-print-directory show-d_script
	@echo :d_subdir:
	@$(MAKE) --no-print-directory show-d_subdir
	@echo :d_symlink:
	@$(MAKE) --no-print-directory show-d_symlink

PREFIX ?= $(HOME)
# XXX: $(HOME)/dotfiles _must_ be this repo.
srcdir_from_prefix = dotfiles
LN ?= ln
MKDIR_P ?= mkdir -p
ifndef V
QUIET_LN = @echo "LN $@";
QUIET_DIR = @echo "MKDIR_P $@";
endif

# $1 is a directory path
# The path _cannot_ have spaces.
dir-depth = $(words $(subst /, ,$(1)))

# $1 = list of locations under dotfiles
to-home-dir = $1

# $1 = list of locations in home
to-dotfiles-dir = $1

# $1 = dest
# $2 = source
define SYMLINK-RULE
$(call to-d,_,$(1)) : $(1)
	@echo '$(QUIET_LN)$(LN) -i -s $(srcdir_from_prefix)/$$< $$@'
endef

define SUBDIR-RULE
$(call to-d,\%$(1)) : FORCE
	@echo '$(QUIET_DIR)$(MKDIR_P) $$@'
endef

define SCRIPT-RULE
$(call to-d,(1)) : $(1)
	@echo './$$< $$@'
endef

$(foreach I,$(s_subdir),$(eval $(call SUBDIR-RULE,$(I))))
$(foreach I,$(s_symlink),$(eval $(call SYMLINK-RULE,$(I))))
$(foreach I,$(s_script),$(eval $(call SCRIPT-RULE,$(I))))

.PHONY: FORCE

all:: $(foreach t,$(TYPES),$(d_$(t)))
