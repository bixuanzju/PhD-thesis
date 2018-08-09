
OTT_LOC    = ./spec/

OTT_OPTS  = -tex_show_meta false

OTT_FILES  = $(OTT_LOC)/*.ott

MAIN = Thesis

SCRIPT = script

OTT_GEN = ott-rules.tex

AUTOGEN = Sources/Conclusion.mng Sources/Appendix.mng Sources/Background.mng Sources/Traits/typesystem.mng Sources/Nested/typesystem.mng Sources/Coherence/coherence_poly.mng Sources/Coherence/coherence_simple.mng Sources/Nested/algorithm.mng Sources/Poly/typesystem.mng Sources/Poly/disjoint.mng Sources/Poly/overview.mng Sources/Poly/elaboration.mng

WARN_MSG = "%%% !!! WARNING: AUTO GENERATED. DO NOT MODIFY !!! %%%\n"

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex $(wildcard Sources/Traits/*.tex) $(wildcard Sources/Poly/*.tex) $(wildcard Sources/Nested/*.tex) $(wildcard Sources/*.tex) $(AUTOGEN)
	@ruby $(SCRIPT).rb
	@latexmk $(@:.pdf=.tex)

$(OTT_GEN): $(OTT_FILES)
	ott -tex_wrap false $(OTT_OPTS) -o $@ $^
	@if grep '<<no parses (' $@ >/dev/null 2>&1 && \
		[ -z "$(DONTSTOP)" ]; then \
			echo; \
			echo "***** OTT PARSE ERROR(S) *****"; \
			grep -n '<<no parses (' $@; \
			$(RM) $@; \
			exit 1; \
	fi >&2


%.mng: %.tex $(OTT_GEN)
	ott -tex_wrap false $(OTT_OPTS) -tex_filter $*.tex $*.mng $(OTT_FILES)
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
