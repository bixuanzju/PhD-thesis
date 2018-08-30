
OTT_LOC    = ./spec

OTT_OPTS  =  -tex_wrap false -tex_show_meta false

OTT_FILES  = $(OTT_LOC)/*.ott

MAIN = Thesis

SCRIPT = script

OTT_GEN = ott-rules.tex

AUTOGEN = $(wildcard Sources/*.mng) $(wildcard Sources/Traits/*.mng) $(wildcard Sources/Nested/*.mng) $(wildcard Sources/Coherence/*.mng) $(wildcard Sources/Poly/*.mng)

WARN_MSG = "%%% !!! WARNING: AUTO GENERATED. DO NOT MODIFY !!! %%%\n"

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex $(wildcard Sources/Traits/*.tex) $(wildcard Sources/Poly/*.tex) $(wildcard Sources/Nested/*.tex) $(wildcard Sources/*.tex) $(AUTOGEN)
	@ruby $(SCRIPT).rb
	@latexmk $(@:.pdf=.tex)

$(OTT_GEN): $(OTT_FILES)
	ott $(OTT_OPTS) -o $@ $^
	@if grep '<<no parses (' $@ >/dev/null 2>&1 && \
		[ -z "$(DONTSTOP)" ]; then \
			echo; \
			echo "***** OTT PARSE ERROR(S) *****"; \
			grep -n '<<no parses (' $@; \
			$(RM) $@; \
			exit 1; \
	fi >&2


%.mng: %.tex $(OTT_GEN)
	ott $(OTT_OPTS) -tex_filter $*.tex $*.mng $(OTT_FILES)
	@perl -pi -e 'print $(WARN_MSG) if $$. == 1' $@

clean:
	@latexmk -c

.PHONY: all clean
