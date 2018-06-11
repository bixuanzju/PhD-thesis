
OTT_LOC    = ../spec/

OTT_OPTS  = -tex_show_meta false

NESTED_FILES  = $(OTT_LOC)/source.ott $(OTT_LOC)/target.ott

TRAIT_FILES  = $(OTT_LOC)/traits.ott

MAIN = Thesis

SCRIPT = script

NESTED_OTT = ott-nested.tex

TRAITS_OTT = ott-traits.tex

AUTOGEN = Sources/Nested/typesystem.mng Sources/Nested/coherence.mng Sources/Nested/algorithm.mng

WARN_MSG = "%%% !!! WARNING: AUTO GENERATED. DO NOT MODIFY !!! %%%\n"

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex $(wildcard Sources/Traits/*.tex) $(wildcard Sources/Nested/*.tex) $(wildcard Sources/*.tex) $(AUTOGEN)
	@ruby $(SCRIPT).rb
	@latexmk $(@:.pdf=.tex)

$(NESTED_OTT): $(NESTED_FILES)
	ott -tex_wrap false $(OTT_OPTS) -o $@ $^
	@if grep '<<no parses (' $@ >/dev/null 2>&1 && \
		[ -z "$(DONTSTOP)" ]; then \
			echo; \
			echo "***** OTT PARSE ERROR(S) *****"; \
			grep -n '<<no parses (' $@; \
			$(RM) $@; \
			exit 1; \
	fi >&2

$(TRAITS_OTT): $(TRAIT_FILES)
	ott -tex_wrap false $(OTT_OPTS) -o $@ $^
	@if grep '<<no parses (' $@ >/dev/null 2>&1 && \
		[ -z "$(DONTSTOP)" ]; then \
			echo; \
			echo "***** OTT PARSE ERROR(S) *****"; \
			grep -n '<<no parses (' $@; \
			$(RM) $@; \
			exit 1; \
	fi >&2


%.mng: %.tex $(NESTED_OTT)
	ott -tex_wrap false $(OTT_OPTS) -tex_filter $*.tex $*.mng $(NESTED_FILES)
	@perl -pi -e 'print $(WARN_MSG) if $$. == 1' $@
	@if grep '<<no parses (' $@ >/dev/null 2>&1 && \
		[ -z "$(DONTSTOP)" ]; then \
			echo; \
			echo "***** OTT PARSE ERROR(S) *****"; \
			grep -n '<<no parses (' $@; \
			$(RM) $@; \
			exit 1; \
	fi >&2

clean:
	@latexmk -c

.PHONY: all clean
