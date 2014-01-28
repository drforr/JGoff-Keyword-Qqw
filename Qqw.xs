/*
Copyright 2012 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
 */

#ifdef __GNUC__
 #if (__GNUC__ == 4 && __GNUC_MINOR__ >= 6) || __GNUC__ >= 5
  #define PRAGMA_GCC_(X) _Pragma(#X)
  #define PRAGMA_GCC(X) PRAGMA_GCC_(GCC X)
 #endif
#endif

#ifndef PRAGMA_GCC
 #define PRAGMA_GCC(X)
#endif

#ifdef DEVEL
 #define WARNINGS_RESET PRAGMA_GCC(diagnostic pop)
 #define WARNINGS_ENABLEW(X) PRAGMA_GCC(diagnostic warning #X)
 #define WARNINGS_ENABLE \
 	WARNINGS_ENABLEW(-Wall) \
 	WARNINGS_ENABLEW(-Wextra) \
 	WARNINGS_ENABLEW(-Wundef) \
 	/* WARNINGS_ENABLEW(-Wshadow) :-( */ \
 	WARNINGS_ENABLEW(-Wbad-function-cast) \
 	WARNINGS_ENABLEW(-Wcast-align) \
 	WARNINGS_ENABLEW(-Wwrite-strings) \
 	/* WARNINGS_ENABLEW(-Wnested-externs) wtf? */ \
 	WARNINGS_ENABLEW(-Wstrict-prototypes) \
 	WARNINGS_ENABLEW(-Wmissing-prototypes) \
 	WARNINGS_ENABLEW(-Winline) \
 	WARNINGS_ENABLEW(-Wdisabled-optimization)

#else
 #define WARNINGS_RESET
 #define WARNINGS_ENABLE
#endif


#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <string.h>


WARNINGS_ENABLE


#define HAVE_PERL_VERSION(R, V, S) \
	(PERL_REVISION > (R) || (PERL_REVISION == (R) && (PERL_VERSION > (V) || (PERL_VERSION == (V) && (PERL_SUBVERSION >= (S))))))

#if HAVE_PERL_VERSION(5, 16, 0)
 #define IF_HAVE_PERL_5_16(YES, NO) YES
#else
 #define IF_HAVE_PERL_5_16(YES, NO) NO
#endif

#if 0
 #if HAVE_PERL_VERSION(5, 17, 6)
  #error "internal error: missing definition of KEY_my (your perl is too new)"
 #elif HAVE_PERL_VERSION(5, 15, 8)
  #define S_KEY_my 134
 #elif HAVE_PERL_VERSION(5, 15, 6)
  #define S_KEY_my 133
 #elif HAVE_PERL_VERSION(5, 15, 5)
  #define S_KEY_my 132
 #elif HAVE_PERL_VERSION(5, 13, 0)
  #define S_KEY_my 131
 #else
  #error "internal error: missing definition of KEY_my (your perl is too old)"
 #endif
#endif


#define MY_PKG "JGoff::Keyword::Qqw"

#define HINTK_KEYWORDS MY_PKG "/keywords"
#define HINTK_FLAGS_   MY_PKG "/flags:"
#define HINTK_SHIFT_   MY_PKG "/shift:"
#define HINTK_ATTRS_   MY_PKG "/attrs:"
#define HINTK_REIFY_   MY_PKG "/reify:"

#define DEFSTRUCT(T) typedef struct T T; struct T

enum {
	FLAG_NAME_OK      = 0x001,
	FLAG_ANON_OK      = 0x002,
	FLAG_DEFAULT_ARGS = 0x004,
	FLAG_CHECK_NARGS  = 0x008,
	FLAG_INVOCANT     = 0x010,
	FLAG_NAMED_PARAMS = 0x020,
	FLAG_TYPES_OK     = 0x040,
	FLAG_CHECK_TARGS  = 0x080,
	FLAG_RUNTIME      = 0x100
};

DEFSTRUCT(KWSpec) {
	unsigned flags;
	I32 reify_type;
	SV *shift;
	SV *attrs;
};

static int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);

DEFSTRUCT(Resource) {
	Resource *next;
	void *data;
	void (*destroy)(pTHX_ void *);
};

typedef Resource *Sentinel[1];

static void sentinel_clear_void(pTHX_ void *p) {
	Resource **pp = p;
	while (*pp) {
		Resource *cur = *pp;
		if (cur->destroy) {
			cur->destroy(aTHX_ cur->data);
		}
		cur->data = (void *)"no";
		cur->destroy = NULL;
		*pp = cur->next;
		Safefree(cur);
	}
}

static Resource *sentinel_register(Sentinel sen, void *data, void (*destroy)(pTHX_ void *)) {
	Resource *cur;

	Newx(cur, 1, Resource);
	cur->data = data;
	cur->destroy = destroy;
	cur->next = *sen;
	*sen = cur;

	return cur;
}

static void sentinel_disarm(Resource *p) {
	p->destroy = NULL;
}

static void my_sv_refcnt_dec_void(pTHX_ void *p) {
	SV *sv = p;
	SvREFCNT_dec(sv);
}

static SV *sentinel_mortalize(Sentinel sen, SV *sv) {
	sentinel_register(sen, sv, my_sv_refcnt_dec_void);
	return sv;
}


#if HAVE_PERL_VERSION(5, 17, 2)
 #define MY_OP_SLABBED(O) ((O)->op_slabbed)
#else
 #define MY_OP_SLABBED(O) 0
#endif

DEFSTRUCT(OpGuard) {
	OP *op;
	bool needs_freed;
};

static void op_guard_init(OpGuard *p) {
	p->op = NULL;
	p->needs_freed = FALSE;
}

static OpGuard op_guard_transfer(OpGuard *p) {
	OpGuard r = *p;
	op_guard_init(p);
	return r;
}

static OP *op_guard_relinquish(OpGuard *p) {
	OP *o = p->op;
	op_guard_init(p);
	return o;
}

static void op_guard_update(OpGuard *p, OP *o) {
	p->op = o;
	p->needs_freed = o && !MY_OP_SLABBED(o);
}

static void op_guard_clear(pTHX_ OpGuard *p) {
	if (p->needs_freed) {
		op_free(p->op);
	}
}

static void free_op_guard_void(pTHX_ void *vp) {
	OpGuard *p = vp;
	op_guard_clear(aTHX_ p);
	Safefree(p);
}

#define sv_eq_pvs(SV, S) my_sv_eq_pvn(aTHX_ SV, "" S "", sizeof (S) - 1)


#include "padop_on_crack.c.inc"


enum {
	MY_ATTR_LVALUE = 0x01,
	MY_ATTR_METHOD = 0x02,
	MY_ATTR_SPECIAL = 0x04
};

static void my_sv_cat_c(pTHX_ SV *sv, U32 c) {
	char ds[UTF8_MAXBYTES + 1], *d;
	d = (char *)uvchr_to_utf8((U8 *)ds, c);
	if (d - ds > 1) {
		sv_utf8_upgrade(sv);
	}
	sv_catpvn(sv, ds, d - ds);
}


#define MY_UNI_IDFIRST(C) isIDFIRST_uni(C)
#define MY_UNI_IDCONT(C)  isALNUM_uni(C)

static SV *my_scan_word(pTHX_ Sentinel sen, bool allow_package) {
	bool at_start, at_substart;
	I32 c;
	SV *sv = sentinel_mortalize(sen, newSVpvs(""));
	if (lex_bufutf8()) {
		SvUTF8_on(sv);
	}

	at_start = at_substart = TRUE;
	c = lex_peek_unichar(0);

	while (c != -1) {
		if (at_substart ? MY_UNI_IDFIRST(c) : MY_UNI_IDCONT(c)) {
			lex_read_unichar(0);
			my_sv_cat_c(aTHX_ sv, c);
			at_substart = FALSE;
			c = lex_peek_unichar(0);
		} else if (allow_package && !at_substart && c == '\'') {
			lex_read_unichar(0);
			c = lex_peek_unichar(0);
			if (!MY_UNI_IDFIRST(c)) {
				lex_stuff_pvs("'", 0);
				break;
			}
			sv_catpvs(sv, "'");
			at_substart = TRUE;
		} else if (allow_package && (at_start || !at_substart) && c == ':') {
			lex_read_unichar(0);
			if (lex_peek_unichar(0) != ':') {
				lex_stuff_pvs(":", 0);
				break;
			}
			lex_read_unichar(0);
			c = lex_peek_unichar(0);
			if (!MY_UNI_IDFIRST(c)) {
				lex_stuff_pvs("::", 0);
				break;
			}
			sv_catpvs(sv, "::");
			at_substart = TRUE;
		} else {
			break;
		}
		at_start = FALSE;
	}

	return SvCUR(sv) ? sv : NULL;
}

static SV *parse_type(pTHX_ Sentinel, const SV *);

DEFSTRUCT(Param) {
	SV *name;
	PADOFFSET padoff;
	SV *type;
};

DEFSTRUCT(ParamInit) {
	Param param;
	OpGuard init;
};

#define VEC(B) B ## _Vec

#define DEFVECTOR(B) DEFSTRUCT(VEC(B)) { \
	B (*data); \
	size_t used, size; \
}

DEFVECTOR(Param);
DEFVECTOR(ParamInit);

#define DEFVECTOR_INIT(N, B) static void N(VEC(B) *p) { \
	p->used = 0; \
	p->size = 23; \
	Newx(p->data, p->size, B); \
} static void N(VEC(B) *)

DEFSTRUCT(ParamSpec) {
	Param invocant;
	VEC(Param) positional_required;
	VEC(ParamInit) positional_optional;
	VEC(Param) named_required;
	VEC(ParamInit) named_optional;
	Param slurpy;
	PADOFFSET rest_hash;
};

DEFVECTOR_INIT(pv_init, Param);
DEFVECTOR_INIT(piv_init, ParamInit);

static void p_init(Param *p) {
	p->name = NULL;
	p->padoff = NOT_IN_PAD;
	p->type = NULL;
}

/* {{{ ps_init */
static void ps_init(ParamSpec *ps) {
	p_init(&ps->invocant);
	pv_init(&ps->positional_required);
	piv_init(&ps->positional_optional);
	pv_init(&ps->named_required);
	piv_init(&ps->named_optional);
	p_init(&ps->slurpy);
	ps->rest_hash = NOT_IN_PAD;
}
/* }}} */

#define DEFVECTOR_EXTEND(N, B) static B (*N(VEC(B) *p)) { \
	assert(p->used <= p->size); \
	if (p->used == p->size) { \
		const size_t n = p->size / 2 * 3 + 1; \
		Renew(p->data, n, B); \
		p->size = n; \
	} \
	return &p->data[p->used]; \
} static B (*N(VEC(B) *))

DEFVECTOR_EXTEND(pv_extend, Param);
DEFVECTOR_EXTEND(piv_extend, ParamInit);

#define DEFVECTOR_CLEAR(N, B, F) static void N(pTHX_ VEC(B) *p) { \
	while (p->used) { \
		p->used--; \
		F(aTHX_ &p->data[p->used]); \
	} \
	Safefree(p->data); \
	p->data = NULL; \
	p->size = 0; \
} static void N(pTHX_ VEC(B) *)

static void p_clear(pTHX_ Param *p) {
	p->name = NULL;
	p->padoff = NOT_IN_PAD;
	p->type = NULL;
}

static void pi_clear(pTHX_ ParamInit *pi) {
	p_clear(aTHX_ &pi->param);
	op_guard_clear(aTHX_ &pi->init);
}

DEFVECTOR_CLEAR(pv_clear, Param, p_clear);
DEFVECTOR_CLEAR(piv_clear, ParamInit, pi_clear);

/* {{{ ps_clear */
static void ps_clear(pTHX_ ParamSpec *ps) {
	p_clear(aTHX_ &ps->invocant);

	pv_clear(aTHX_ &ps->positional_required);
	piv_clear(aTHX_ &ps->positional_optional);

	pv_clear(aTHX_ &ps->named_required);
	piv_clear(aTHX_ &ps->named_optional);

	p_clear(aTHX_ &ps->slurpy);
}
/* }}} */

/* {{{ ps_contains */
static int ps_contains(pTHX_ const ParamSpec *ps, SV *sv) {
	size_t i, lim;

	if (ps->invocant.name && sv_eq(sv, ps->invocant.name)) {
		return 1;
	}

	for (i = 0, lim = ps->positional_required.used; i < lim; i++) {
		if (sv_eq(sv, ps->positional_required.data[i].name)) {
			return 1;
		}
	}

	for (i = 0, lim = ps->positional_optional.used; i < lim; i++) {
		if (sv_eq(sv, ps->positional_optional.data[i].param.name)) {
			return 1;
		}
	}

	for (i = 0, lim = ps->named_required.used; i < lim; i++) {
		if (sv_eq(sv, ps->named_required.data[i].name)) {
			return 1;
		}
	}

	for (i = 0, lim = ps->named_optional.used; i < lim; i++) {
		if (sv_eq(sv, ps->named_optional.data[i].param.name)) {
			return 1;
		}
	}

	return 0;
}
/* }}} */

static void ps_free_void(pTHX_ void *p) {
	ps_clear(aTHX_ p);
	Safefree(p);
}

static size_t count_named_params(const ParamSpec *ps) {
	return ps->named_required.used + ps->named_optional.used;
}

enum {
	PARAM_INVOCANT = 0x01,
	PARAM_NAMED    = 0x02
};

/* {{{ parse_param */
static PADOFFSET parse_param(
	pTHX_
	Sentinel sen,
	const SV *declarator, const KWSpec *spec, ParamSpec *param_spec,
	int *pflags, SV **pname, OpGuard *ginit, SV **ptype,
	I32 start_delim, I32 end_delim
) {
	I32 c;
	char sigil;
	SV *name;

	assert(!ginit->op);
	*pflags = 0;
	*ptype = NULL;

	c = lex_peek_unichar(0);

	switch(c) {
		case -1:
			croak("In %"SVf": unterminated parameter list", SVfARG(declarator));
		case '$':
		case '@':
		case '%':
			sigil = c;

			lex_read_unichar(0);
			lex_read_space(0);

			if (!(name = my_scan_word(aTHX_ sen, FALSE))) {
				croak("In %"SVf": missing identifier after '%c'", SVfARG(declarator), sigil);
			}
			sv_insert(name, 0, 0, &sigil, 1);
			*pname = name;
			break;
		default:
			croak("In %"SVf": unexpected '%c' in parameter list (expecting a sigil)", SVfARG(declarator), (int)c);
	}

	lex_read_space(0);
	c = lex_peek_unichar(0);

	if (c == ',') {
		lex_read_unichar(0);
		lex_read_space(0);
	} else if (c != end_delim) {
		if (c == -1) {
			croak("In %"SVf": unterminated parameter list", SVfARG(declarator));
		}
		croak("In %"SVf": unexpected '%c' in parameter list (expecting ',')", SVfARG(declarator), (int)c);
	}

	return pad_add_name_sv(*pname, IF_HAVE_PERL_5_16(padadd_NO_DUP_CHECK, 0), NULL, NULL);
}
/* }}} */

/* {{{ register_info */
static void register_info(pTHX_ UV key, SV *declarator, const KWSpec *kws, const ParamSpec *ps) {
	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK(SP);
	EXTEND(SP, 10);

	/* 0 */ {
		mPUSHu(key);
	}
	/* 1 */ {
		STRLEN n;
		char *p = SvPV(declarator, n);
		char *q = memchr(p, ' ', n);
		SV *tmp = newSVpvn_utf8(p, q ? (size_t)(q - p) : n, SvUTF8(declarator));
		mPUSHs(tmp);
	}
	if (!ps) {
		if (SvTRUE(kws->shift)) {
			PUSHs(kws->shift);
		} else {
			PUSHmortal;
		}
		PUSHmortal;
		mPUSHs(newRV_noinc((SV *)newAV()));
		mPUSHs(newRV_noinc((SV *)newAV()));
		mPUSHs(newRV_noinc((SV *)newAV()));
		mPUSHs(newRV_noinc((SV *)newAV()));
		mPUSHp("@_", 2);
		PUSHmortal;
	} else {
		/* 2, 3 */ {
			if (ps->invocant.name) {
				PUSHs(ps->invocant.name);
				if (ps->invocant.type) {
					PUSHs(ps->invocant.type);
				} else {
					PUSHmortal;
				}
			} else {
				PUSHmortal;
				PUSHmortal;
			}
		}
		/* 4 */ {
			size_t i, lim;
			AV *av;

			lim = ps->positional_required.used;

			av = newAV();
			if (lim) {
				av_extend(av, (lim - 1) * 2);
				for (i = 0; i < lim; i++) {
					Param *cur = &ps->positional_required.data[i];
					av_push(av, SvREFCNT_inc_simple_NN(cur->name));
					av_push(av, cur->type ? SvREFCNT_inc_simple_NN(cur->type) : &PL_sv_undef);
				}
			}

			mPUSHs(newRV_noinc((SV *)av));
		}
		/* 5 */ {
			size_t i, lim;
			AV *av;

			lim = ps->positional_optional.used;

			av = newAV();
			if (lim) {
				av_extend(av, (lim - 1) * 2);
				for (i = 0; i < lim; i++) {
					Param *cur = &ps->positional_optional.data[i].param;
					av_push(av, SvREFCNT_inc_simple_NN(cur->name));
					av_push(av, cur->type ? SvREFCNT_inc_simple_NN(cur->type) : &PL_sv_undef);
				}
			}

			mPUSHs(newRV_noinc((SV *)av));
		}
		/* 6 */ {
			size_t i, lim;
			AV *av;

			lim = ps->named_required.used;

			av = newAV();
			if (lim) {
				av_extend(av, (lim - 1) * 2);
				for (i = 0; i < lim; i++) {
					Param *cur = &ps->named_required.data[i];
					av_push(av, SvREFCNT_inc_simple_NN(cur->name));
					av_push(av, cur->type ? SvREFCNT_inc_simple_NN(cur->type) : &PL_sv_undef);
				}
			}

			mPUSHs(newRV_noinc((SV *)av));
		}
		/* 7 */ {
			size_t i, lim;
			AV *av;

			lim = ps->named_optional.used;

			av = newAV();
			if (lim) {
				av_extend(av, (lim - 1) * 2);
				for (i = 0; i < lim; i++) {
					Param *cur = &ps->named_optional.data[i].param;
					av_push(av, SvREFCNT_inc_simple_NN(cur->name));
					av_push(av, cur->type ? SvREFCNT_inc_simple_NN(cur->type) : &PL_sv_undef);
				}
			}

			mPUSHs(newRV_noinc((SV *)av));
		}
		/* 8, 9 */ {
			if (ps->slurpy.name) {
				PUSHs(ps->slurpy.name);
				if (ps->slurpy.type) {
					PUSHs(ps->slurpy.type);
				} else {
					PUSHmortal;
				}
			} else {
				PUSHmortal;
				PUSHmortal;
			}
		}
	}
	PUTBACK;

	call_pv(MY_PKG "::_register_info", G_VOID);

	FREETMPS;
	LEAVE;
}
/* }}} */

/* {{{ end_delimiter */
static I32 end_delimiter ( I32 start_delim ) {
	switch (start_delim) {
		/* Handle the balanced characters specially. */
		case '(':	return ')';
		case '{':	return '}';
		case '<':	return '>';
		case '[':	return ']';
		default:	return start_delim;
	}
}
/* }}} */

/* {{{ parse_fun */
static int parse_fun(pTHX_ Sentinel sen, OP **pop, const char *keyword_ptr, STRLEN keyword_len, const KWSpec *spec) {
	ParamSpec *param_spec;
	SV *declarator;
	I32 floor_ix;
	OpGuard *prelude_sentinel;
	I32 c;
	I32 start_delim;

	declarator =
		sentinel_mortalize(sen, newSVpvn(keyword_ptr, keyword_len));
	if (lex_bufutf8()) {
		SvUTF8_on(declarator);
	}

	lex_read_space(0);

	/* initialize synthetic optree */
	Newx(prelude_sentinel, 1, OpGuard);
	op_guard_init(prelude_sentinel);
	sentinel_register(sen, prelude_sentinel, free_op_guard_void);

	/* parameters */
	param_spec = NULL;

	c = lex_peek_unichar(0);
	/* Skip whitespace after the token, but this is a special case now. */
	if (c == ' ') {
		lex_read_unichar(0);
		c = lex_peek_unichar(0);
	}
	
	if ( 1 ) { /* Pretty much any character should work at this point. */
		I32 start_delim = c;
		OpGuard *init_sentinel;
		I32 end_delim = end_delimiter(c);

		Newx(init_sentinel, 1, OpGuard);
		op_guard_init(init_sentinel);
		sentinel_register(sen, init_sentinel, free_op_guard_void);

		Newx(param_spec, 1, ParamSpec);
		ps_init(param_spec);
		sentinel_register(sen, param_spec, ps_free_void);

		lex_read_unichar(0);
		lex_read_space(0);

		while ((c = lex_peek_unichar(0)) != end_delim) {
			int flags;
			SV *name, *type;
			char sigil;
			PADOFFSET padoff;

			padoff = parse_param(aTHX_ sen, declarator, spec, param_spec, &flags, &name, init_sentinel, &type, start_delim, end_delim);

			S_intro_my(aTHX);

			sigil = SvPV_nolen(name)[0];

			/* internal consistency */
			if (flags & PARAM_NAMED) {
				if (flags & PARAM_INVOCANT) {
					croak("In %"SVf": invocant %"SVf" can't be a named parameter", SVfARG(declarator), SVfARG(name));
				}
				if (sigil != '$') {
					croak("In %"SVf": named parameter %"SVf" can't be a%s", SVfARG(declarator), SVfARG(name), sigil == '@' ? "n array" : " hash");
				}
			} else if (flags & PARAM_INVOCANT) {
				if (init_sentinel->op) {
					croak("In %"SVf": invocant %"SVf" can't have a default value", SVfARG(declarator), SVfARG(name));
				}
				if (sigil != '$') {
					croak("In %"SVf": invocant %"SVf" can't be a%s", SVfARG(declarator), SVfARG(name), sigil == '@' ? "n array" : " hash");
				}
			} else if (sigil != '$' && init_sentinel->op) {
				croak("In %"SVf": %s %"SVf" can't have a default value", SVfARG(declarator), sigil == '@' ? "array" : "hash", SVfARG(name));
			}

			/* external constraints */
			if (param_spec->slurpy.name) {
				croak("In %"SVf": I was expecting \")\" after \"%"SVf"\", not \"%"SVf"\"", SVfARG(declarator), SVfARG(param_spec->slurpy.name), SVfARG(name));
			}
			if (sigil != '$') {
				assert(!init_sentinel->op);
				param_spec->slurpy.name = name;
				param_spec->slurpy.padoff = padoff;
				param_spec->slurpy.type = type;
				continue;
			}

			if (!(flags & PARAM_NAMED) && count_named_params(param_spec)) {
				croak("In %"SVf": positional parameter %"SVf" can't appear after named parameter %"SVf"", SVfARG(declarator), SVfARG(name), SVfARG((param_spec->named_required.used ? param_spec->named_required.data[0] : param_spec->named_optional.data[0].param).name));
			}

			if (flags & PARAM_INVOCANT) {
				if (param_spec->invocant.name) {
					croak("In %"SVf": invalid double invocants %"SVf", %"SVf"", SVfARG(declarator), SVfARG(param_spec->invocant.name), SVfARG(name));
				}
				if (count_positional_params(param_spec) || count_named_params(param_spec)) {
					croak("In %"SVf": invocant %"SVf" must be first in parameter list", SVfARG(declarator), SVfARG(name));
				}
				if (!(spec->flags & FLAG_INVOCANT)) {
					croak("In %"SVf": invocant %"SVf" not allowed here", SVfARG(declarator), SVfARG(name));
				}
				param_spec->invocant.name = name;
				param_spec->invocant.padoff = padoff;
				param_spec->invocant.type = type;
				continue;
			}

			if (init_sentinel->op && !(spec->flags & FLAG_DEFAULT_ARGS)) {
				croak("In %"SVf": default argument for %"SVf" not allowed here", SVfARG(declarator), SVfARG(name));
			}

			if (ps_contains(aTHX_ param_spec, name)) {
				croak("In %"SVf": %"SVf" can't appear twice in the same parameter list", SVfARG(declarator), SVfARG(name));
			}

			if (flags & PARAM_NAMED) {
				if (!(spec->flags & FLAG_NAMED_PARAMS)) {
					croak("In %"SVf": named parameter :%"SVf" not allowed here", SVfARG(declarator), SVfARG(name));
				}

				if (init_sentinel->op) {
					ParamInit *pi = piv_extend(&param_spec->named_optional);
					pi->param.name = name;
					pi->param.padoff = padoff;
					pi->param.type = type;
					pi->init = op_guard_transfer(init_sentinel);
					param_spec->named_optional.used++;
				} else {
					Param *p;

					if (param_spec->positional_optional.used) {
						croak("In %"SVf": can't combine optional positional (%"SVf") and required named (%"SVf") parameters", SVfARG(declarator), SVfARG(param_spec->positional_optional.data[0].param.name), SVfARG(name));
					}

					p = pv_extend(&param_spec->named_required);
					p->name = name;
					p->padoff = padoff;
					p->type = type;
					param_spec->named_required.used++;
				}
			} else {
				if (init_sentinel->op || param_spec->positional_optional.used) {
					ParamInit *pi = piv_extend(&param_spec->positional_optional);
					pi->param.name = name;
					pi->param.padoff = padoff;
					pi->param.type = type;
					pi->init = op_guard_transfer(init_sentinel);
					param_spec->positional_optional.used++;
				} else {
					Param *p = pv_extend(&param_spec->positional_required);
					p->name = name;
					p->padoff = padoff;
					p->type = type;
					param_spec->positional_required.used++;
				}
			}

		}
		lex_read_unichar(0);
		lex_read_space(0);
	}

	/* it's go time. */
	*pop = newSVOP( OP_CONST, 0, newSVpvn_flags( "a", 1, 0 ) );
	*pop = op_append_elem( OP_LIST, *pop,
			       newSVOP( OP_CONST, 0,
					newSVpvn_flags( "b", 1, 0 ) ) );

	return KEYWORD_PLUGIN_EXPR;
}
/* }}} */

/* {{{ kw_flags_enter */
static int kw_flags_enter(pTHX_ Sentinel sen, const char *kw_ptr, STRLEN kw_len, KWSpec *spec) {
	HV *hints;
	SV *sv, **psv;
	const char *p, *kw_active;
	STRLEN kw_active_len;
	bool kw_is_utf8;

	if (!(hints = GvHV(PL_hintgv))) {
		return FALSE;
	}
	if (!(psv = hv_fetchs(hints, HINTK_KEYWORDS, 0))) {
		return FALSE;
	}
	sv = *psv;
	kw_active = SvPV(sv, kw_active_len);
	if (kw_active_len <= kw_len) {
		return FALSE;
	}

	kw_is_utf8 = lex_bufutf8();

	for (
		p = kw_active;
		(p = strchr(p, *kw_ptr)) &&
		p < kw_active + kw_active_len - kw_len;
		p++
	) {
		if (
			(p == kw_active || p[-1] == ' ') &&
			p[kw_len] == ' ' &&
			memcmp(kw_ptr, p, kw_len) == 0
		) {
			ENTER;
			SAVETMPS;

			SAVEDESTRUCTOR_X(sentinel_clear_void, sen);

			spec->flags = 0;
			spec->reify_type = 0;
			spec->shift = sentinel_mortalize(sen, newSVpvs(""));
			spec->attrs = sentinel_mortalize(sen, newSVpvs(""));

#define FETCH_HINTK_INTO(NAME, PTR, LEN, X) STMT_START { \
	const char *fk_ptr_; \
	STRLEN fk_len_; \
	I32 fk_xlen_; \
	SV *fk_sv_; \
	fk_sv_ = sentinel_mortalize(sen, newSVpvs(HINTK_ ## NAME)); \
	sv_catpvn(fk_sv_, PTR, LEN); \
	fk_ptr_ = SvPV(fk_sv_, fk_len_); \
	fk_xlen_ = fk_len_; \
	if (kw_is_utf8) { \
		fk_xlen_ = -fk_xlen_; \
	} \
	if (!((X) = hv_fetch(hints, fk_ptr_, fk_xlen_, 0))) { \
		croak("%s: internal error: $^H{'%.*s'} not set", MY_PKG, (int)fk_len_, fk_ptr_); \
	} \
} STMT_END

			FETCH_HINTK_INTO(FLAGS_, kw_ptr, kw_len, psv);
			spec->flags = SvIV(*psv);

			FETCH_HINTK_INTO(REIFY_, kw_ptr, kw_len, psv);
			spec->reify_type = SvIV(*psv);

			FETCH_HINTK_INTO(SHIFT_, kw_ptr, kw_len, psv);
			SvSetSV(spec->shift, *psv);

			FETCH_HINTK_INTO(ATTRS_, kw_ptr, kw_len, psv);
			SvSetSV(spec->attrs, *psv);

#undef FETCH_HINTK_INTO
			return TRUE;
		}
	}
	return FALSE;
}
/* }}} */

/* {{{ my_keyword_plugin */
static int my_keyword_plugin(pTHX_ char *keyword_ptr, STRLEN keyword_len, OP **op_ptr) {
	Sentinel sen = { NULL };
	KWSpec spec;
	int ret;

	if (kw_flags_enter(aTHX_ sen, keyword_ptr, keyword_len, &spec)) {
		/* scope was entered, 'sen' and 'spec' are initialized */
		ret = parse_fun(aTHX_ sen, op_ptr, keyword_ptr, keyword_len, &spec);
		FREETMPS;
		LEAVE;
	} else {
		/* not one of our keywords, no allocation done */
		ret = next_keyword_plugin(aTHX_ keyword_ptr, keyword_len, op_ptr);
	}

	return ret;
}
/* }}} */

#ifndef SvREFCNT_dec_NN
#define SvREFCNT_dec_NN(SV) SvREFCNT_dec(SV)
#endif

#ifndef assert_
#ifdef DEBUGGING
#define assert_(X) assert(X),
#else
#define assert_(X)
#endif
#endif

#ifndef gv_method_changed
#define gv_method_changed(GV) (              \
	assert_(isGV_with_GP(GV))                \
	GvREFCNT(GV) > 1                         \
		? (void)PL_sub_generation++          \
		: mro_method_changed_in(GvSTASH(GV)) \
)
#endif

WARNINGS_RESET

MODULE = JGoff::Keyword::Qqw   PACKAGE = JGoff::Keyword::Qqw   PREFIX = fp_
PROTOTYPES: ENABLE

UV
fp__cv_root(sv)
	SV *sv
	PREINIT:
		CV *xcv;
		HV *hv;
		GV *gv;
	CODE:
		xcv = sv_2cv(sv, &hv, &gv, 0);
		RETVAL = PTR2UV(xcv ? CvROOT(xcv) : NULL);
	OUTPUT:
		RETVAL

void
fp__defun(name, body)
	SV *name
	CV *body
	PREINIT:
		GV *gv;
		CV *xcv;
	CODE:
		assert(SvTYPE(body) == SVt_PVCV);
		gv = gv_fetchsv(name, GV_ADDMULTI, SVt_PVCV);
		xcv = GvCV(gv);
		if (xcv) {
			if (!GvCVGEN(gv) && (CvROOT(xcv) || CvXSUB(xcv)) && ckWARN(WARN_REDEFINE)) {
				warner(packWARN(WARN_REDEFINE), "Subroutine %"SVf" redefined", SVfARG(name));
			}
			SvREFCNT_dec_NN(xcv);
		}
		GvCVGEN(gv) = 0;
		GvASSUMECV_on(gv);
		if (GvSTASH(gv)) {
			gv_method_changed(gv);
		}
		GvCV_set(gv, (CV *)SvREFCNT_inc_simple_NN(body));
		CvGV_set(body, gv);
		CvANON_off(body);

BOOT:
WARNINGS_ENABLE {
	HV *const stash = gv_stashpvs(MY_PKG, GV_ADD);
	/**/
	newCONSTSUB(stash, "FLAG_NAME_OK",      newSViv(FLAG_NAME_OK));
	newCONSTSUB(stash, "FLAG_ANON_OK",      newSViv(FLAG_ANON_OK));
	newCONSTSUB(stash, "FLAG_DEFAULT_ARGS", newSViv(FLAG_DEFAULT_ARGS));
	newCONSTSUB(stash, "FLAG_CHECK_NARGS",  newSViv(FLAG_CHECK_NARGS));
	newCONSTSUB(stash, "FLAG_INVOCANT",     newSViv(FLAG_INVOCANT));
	newCONSTSUB(stash, "FLAG_NAMED_PARAMS", newSViv(FLAG_NAMED_PARAMS));
	newCONSTSUB(stash, "FLAG_TYPES_OK",     newSViv(FLAG_TYPES_OK));
	newCONSTSUB(stash, "FLAG_CHECK_TARGS",  newSViv(FLAG_CHECK_TARGS));
	newCONSTSUB(stash, "FLAG_RUNTIME",      newSViv(FLAG_RUNTIME));
	newCONSTSUB(stash, "HINTK_KEYWORDS", newSVpvs(HINTK_KEYWORDS));
	newCONSTSUB(stash, "HINTK_FLAGS_",   newSVpvs(HINTK_FLAGS_));
	newCONSTSUB(stash, "HINTK_SHIFT_",   newSVpvs(HINTK_SHIFT_));
	newCONSTSUB(stash, "HINTK_ATTRS_",   newSVpvs(HINTK_ATTRS_));
	newCONSTSUB(stash, "HINTK_REIFY_",   newSVpvs(HINTK_REIFY_));
	/**/
	next_keyword_plugin = PL_keyword_plugin;
	PL_keyword_plugin = my_keyword_plugin;
} WARNINGS_RESET
