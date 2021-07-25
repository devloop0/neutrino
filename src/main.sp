import <"std/io">
import <"std/lib">

import "util/base.hsp"
import "util/hash_table.hsp"
import "util/vector.hsp"
import "util/string.hsp"
import "util/stack.hsp"
import "util/generic_funcs.hsp"
import "util/hash_set.hsp"
import "util/error.hsp"
import "lex/token.hsp"
import "lex/lexer.hsp"
import "parse/parser.hsp"
import "ast/ast.hsp"
import "tck/symtab.hsp"
import "tck/tck.hsp"
import "util/file.hsp"
import "ir/ir.hsp"

using std::io::printf;
using neutrino::util::n_malloc;
using neutrino::util::n_free;
using neutrino::util::n_strdup;
using std::lib::NULL;

using namespace neutrino;

func int main(int argc, char** argv) {
	type util::string* f = util::string_init("/home/artoria/tmp/t.n");
	type util::string* src = util::string_init(
		# "variant Option { None; Some : * mut byte; }\n"
		# "fun malloc(let sz : mut unsigned int) : mut* mut byte;\n"
		# "fun checked_malloc(let mut sz : mut unsigned int) : mut* mut byte {\n"
		# "\tlet mut res = malloc(sz);\n"
		# "\treturn res == 0 as *byte ? Some(res) : None;\n"
		# "}\n"

		# "fun f(): void { let ((a)) = (2, 2); }"

		# "variant Option { None; Some : * mut byte; }\n"
		# "fun malloc(let mut sz : unsigned int) : mut Option;\n"
		# "fun checked_malloc(let mut sz : unsigned int) : mut* mut byte {\n"
		# "\tlet mut res = malloc(sz);\n"
		# "\treturn res == 0 as *byte ? Some(res) : None;\n"
		# "}\n"

		# "variant Option { None; Some : * mut byte; }\n"
		# "fun malloc(let mut sz : unsigned int) : mut* byte;\n"
		# "fun checked_malloc(let mut sz : unsigned int) : mut Option {\n"
		# "\tlet res = malloc(sz);\n"
		# "\treturn res == 0 as *byte ? Some(res) : None;\n"
		# "}\n"

		# "variant Option { None; Some : * mut byte; }\n"
		# "fun malloc(let mut sz : unsigned int) : mut* byte;\n"
		# "fun checked_malloc(let mut sz : unsigned int) : mut Option {\n"
		# "\tlet mut res = malloc(sz);\n"
		# "\treturn res == 0 as *byte ? Some(res) : None;\n"
		# "}\n"

		# /* OK */ "variant Option { None; Some : * mut byte; }\n"
		# "fun malloc(let mut sz : unsigned int) : * mut byte;\n"
		# "fun checked_malloc(let sz : unsigned int) : mut Option {\n"
		# "\tlet mut res = malloc(sz);\n"
		# "\treturn res == 0 as *byte ? None : Some(res);\n"
		# "}"

		# /* OK */ "fun memcpy(let mut dst: * mut byte, let mut src: * byte, let mut x: unsigned int) : mut * mut byte {\n"
		# "\tlet orig = dst;\n"
		# "\twhile (x-- > 0) {\n"
		# "\t(dst@ = src@, dst = dst[1]$, src = src[1]$);\n"
		# "\t}"
		# "\treturn orig;"
		# "}\n"

		# "fun memcpy(let mut dst: * mut byte, let src: *byte, let mut x: unsigned int) : mut* mut byte {\n"
		# "\tlet orig = dst;\n"
		# "\twhile (x-- > 0) {\n"
		# "\t(dst@ = src@, dst = dst[1]$, src = src[1]$);\n"
		# "\t}"
		# "\treturn orig;"
		# "}\n"

		# "fun memcpy(let mut dst: mut byte*, let src: byte*, let mut x: unsigned int) : mut byte* {\n"
		# "\tlet mut iter = src as mut byte*, mut orig = dst;\n"
		# "\twhile (x-- > 0) {\n"
		# "\t(dst@ = iter@, dst = dst[1]$, src = src[1]$);\n"
		# "\t}"
		# "\treturn orig;"
		# "}\n"

		# "fun memcpy(let mut dst: * mut byte, let mut src: *byte, let mut x: unsigned int) : * mut byte{\n"
		# "\tlet mut orig = dst as *byte;\n"
		# "\twhile (x-- > 0) {\n"
		# "\t(dst@ = src@, dst = dst[1]$, src = src[1]$);\n"
		# "\t}"
		# "\treturn orig;"
		# "}\n"

		# "fun send(let mut to : * mut short, let from : * short, let count : unsigned int) : void {\n"
		# "\tlet n = (count + 7) / 8;\n"
		# "\tswitch (count % 8) {\n"
		# "\tcase 0: do { (to@ = from@, from = from[1]$);\n"
		# "\tcase 7:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 6:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 5:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 4:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 3:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 2:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 1:      (to@ = from@, from = from[1]$);\n"
		# "\t       } while (--n > 0);\n"
		# "\t}\n"
		# "}\n"

		# "fun send(let mut to : * mut short, let mut from : * short, let count : unsigned int) : void {\n"
		# "\tlet n = (count + 7) / 8;\n"
		# "\tswitch (count % 8) {\n"
		# "\tcase 0: do { (to@ = from@, from = from[1]$);\n"
		# "\tcase 7:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 6:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 5:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 4:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 3:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 2:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 1:      (to@ = from@, from = from[1]$);\n"
		# "\t       } while (--n > 0);\n"
		# "\t}\n"
		# "}\n"

		# /* OK */ "fun send(let mut to : * mut short, let mut from : * short, let count : unsigned int) : void {\n"
		# "\tlet mut n = (count + 7) / 8;\n"
		# "\tswitch (count % 8) {\n"
		# "\tcase 0: do { (to@ = from@, from = from[1]$);\n"
		# "\tcase 7:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 6:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 5:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 4:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 3:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 2:      (to@ = from@, from = from[1]$);\n"
		# "\tcase 1:      (to@ = from@, from = from[1]$);\n"
		# "\t       } while (--n > 0);\n"
		# "\t}\n"
		# "}\n"

		# "fun main(): void {\n"
		# "let (_, 2) = (2, 2);\n"
		# "}"

		# "let mut x = 2; fun main(): void { let () = (); }"

		# "const x = 1 + 2; fun main() : void { let [2= ...::x] = (1,); }"

		# "fun test(let (x, y, ..., a, b) : (char, short, int, bool, long)) : void {\n"
		# "\treturn x == y && a == 0;\n"
		# "}\n"

		# "fun main(): void {\n"
		# "\tlet t = ((-1) as * int, true, 'x');\n"
		# "\tlet (mut x, (y), ...) = t;\n"
		# "\tlet is_on_x_axis = x@++ == 0 && y;\n"
		# "}"

		# /* OK */ "fun f() : void { 2 as void as mut void; }"
		# "fun f() : void { let a = 2 as void as unsigned int; }"

		# "fun main() : void { let mut x : int; let ({x},) = (\"3\",); }"

		# "namespace n { variant Option { None; Some: *mut byte; } } variant Option { None; Some : *mut byte; } fun main() : void { let n::None () = Some(0 as *mut byte); }"

		# "variant Base { Scalar : unsigned int; Vec2D : (unsigned int, unsigned int); Vec3D : (unsigned int , unsigned int, unsigned int); }\n"
		# "fun test() : Base;\n"
		# "fun main() : void {\n"
		# "\tvariant Base { Vec2D : (unsigned int, unsigned int); }\n"
		# "\tlet Vec2D (x, y) = test();\n"
		# "}"

		# "namespace std { type f32 = float, u32 = unsigned int; }\n"
		# "fun float_to_bits(let f: std::f32) : std::u32 {\n"
		# "\tunion U { f: std::f32; x: std::u32; } let U { .f: f, .x } = U { .f = f };\n"
		# "\treturn x;\n"
		# "}\n"

		# "fun main() : void {\n"
		# "let add = \\ (let x : int, let y: int) : int { return x + y; };\n"
		# "add(2, \"sdf\");\n"
		# "}\n"

		# "fun main() : void {\n"
		# "let tmp = \\ () : int { return; };\n"
		# "}"

		# "variant Option { None; Some : * mut byte; }\n"
		# "type i32 = int;\n"
		# "namespace option_ops {\n"
		# "\tfun unwrap(let opt : Option, let handler : (fn () : void)) : * mut byte {\n"
		# "\t\tmatch (opt) {\n"
		# "\t\t\t::Some (ret) : return ret;\n"
		# "\t\t\t_ : handler();\n"
		# "\t\t}\n"
		# "\t}\n"
		# "}\n\n"
		# "fun main() : void {\n"
		# "\tlet opt : Option;\n"
		# "\tlet res = opt.unwrap!(+\\ () : void { });\n"
		# "}\n"

		# "namespace X { enum E { A, B } type X = E; } fun main() : void { enum E { A, B } type X = E; ::X::X::A == X::B; }"
		# "namespace X { enum E { A, B } type X = E; } fun main() : void { enum E { A, B } using namespace X; }"

		# "variant Option { None; Some: * mut byte; }\n"
		# "namespace std::option_ops {\n"
		# "fun has_value(let opt : * mut Option) : bool {\n"
		# "\tmatch (opt@) {\n"
		# "\t\tNone : return false;\n"
		# "\t\t_ : return true;\n"
		# "\t}\n"
		# "}\n"
		# "}\n"
		# "fun main() : void {\n"
		# "let opt : * Option;\n"
		# "opt->has_value!;\n"
		# "}"

		# "namespace std::types { type i32 = signed int, u32 = unsigned int, f32 = float, f64 = double; }\n"
		# "namespace types = std::types;\n"
		# "using namespace types;\n"
		# "namespace std::i32_ops {\n"
		# "\tfun add(let a : i32, let b : i32) : i32 { return a + b; }\n"
		# "\tfun sub(let a : i32, let b : i32) : i32 { return a - b; }\n"
		# "\tfun mul(let a : i32, let b : i32) : i32 { return a * b; }\n"
		# "\tfun abs(let a : i32) : i32 { return a < 0 ? -a : a; }\n"
		# "}\n"
		# "namespace std::f64_ops {\n"
		# "\tfun add(let a : f64, let b : f64) : f64 { return a + b; }\n"
		# "\tfun sub(let a : f64, let b : f64) : f64 { return a - b; }\n"
		# "\tfun mul(let a : f64, let b : f64) : f64 { return a * b; }\n"
		# "\tfun abs(let a : f64) : f64 { return a < 0 ? -a : a; }\n"
		# "\tfun ipow(let a : f64, let b : u32) : f64;\n"
		# "\tfun to_float(let a : f64) : f32 { return a; }\n"
		# "}\n"
		# "namespace std::f32_ops {\n"
		# "\t// fun abs(let a : f32) : f32 { return a < 0 ? -a : a; }\n"
		# "}\n\n"
		# "fun main() : void {\n"
		# "\t\\ () : void {};\n"
		# "\tlet t : * (double, double);\n"
		# "\tlet l2 = t->[0].sub!(t->[1]).to_float!.abs!.ipow!(2).to_float!.abs!;\n"
		# "}"

		# "namespace std { type u32 = unsigned int, i32 = int; }\n"
		# "fun main() : std::i32 {\n"
		# "\tstruct Point { x, y: std::u32; }\n"
		# "\tstruct Rect { a, b: Point; }\n"
		# "\tlet mut lam = \\ (let (x1, y1) : (std::u32, std::u32), let (x2, y2) : (std::u32, std::u32)) : Rect {\n"
		# "\t\treturn Rect { .a = Point { .x = x1, .y = y1 }, .b = Point { .x = x2, .y = y2 } };\n"
		# "\t};\n"
		# "\tlet mine = Point { .x = 2, .y = 3 };\n"
		# "\treturn 0;\n"
		# "\tlam = \\ (let r : * mut Rect) : void using (* mine) {\n"
		# "\t\t(r->a.x += mine->x, r->a.y += mine->y, r->b.x += mine->x, r->b.y += mine->y);\n"
		# "\t};\n"
		# "}"

		# "namespace std { type u32 = unsigned int; }\n"
		# "fun main() : void {\n"
		# "\tlet counter = 0_ui;\n"
		# "\tlet inc = \\ () : std::u32 using (mut counter) { return counter@++; };\n"
		# "\tfor (let mut i = 0_ui; i < 10; i++) inc();\n"
		# "}"

		# "fun main() : void {\n"
		# "\tlet x = main();\n"
		# "\\ () : void using (* x) {};\n"
		# "}"

		# "namespace std { type u32 = unsigned int; }\n"
		# "let sdf = 1234;\n"
		# "fun main() : void {\n"
		# "\tstruct Point { x, y: std::u32; }\n"
		# "\tstruct Rect { a, b: Point; }\n"
		# "\tlet construct_rect = \\ (let (x1, y1) : (std::u32, std::u32), let (x2, y2) : (std::u32, std::u32)) : Rect {\n"
		# "\t\treturn Rect { .a = Point { .x = x1, .y = y1 }, .b = Point { .x = x2, .y = y2 } };\n"
		# "\t};\n"
		# "\tlet mut point = Point { .x = 2, .y = -3 };\n"
		# "\tlet translate_rect = \\ (let rect : Rect) : void using (sdf) {\n"
		# "\t(rect.a.x += point.x, rect.a.y += point.y, rect.b.x += point.x, rect.b.y += point.y);\n"
		# "\t};"
		# "}\n"

		# "let mut c = \"sdf\";\n"
		# "struct T { _: struct V { x: int; } }\n"
		# "fun main() : void {\n"
		# "\tlet c = 32;\n"
		# "\tstruct T { _: struct V { x: int; } } let m = T::V { .x = 2 };\n"
		# "\ttype V = T::V;\n"
		# "\tlet mut add = \\ (let x : int, let y : int) : int { let s : T::V, t : V = s; return x + y + s.x + c; };\n"
		# "\tadd = \\ (let x : int, let y : int) : int { return x + y; };\n"
		# "}"

		# "namespace detail { const upper_range = \"\"; }\n"
		# "fun test(let i : unsigned int) : void {\n"
		# "\tmatch (i) {\n"
		# "\t\t[1=...=5] : \"Pretty small!\";\n"
		# "\t\t[5 ...=detail::upper_range] : \"Bigger!\";\n"
		# "\t\t_ : \"Huge!\";\n"
		# "\t}"
		# "}"

		# "struct Point { x: unsigned int; y: *char; }\n"
		# "fun test(let x : int, let mut y : int, let res : * Point) : void {\n"
		# "\t`Point { .x: {res->x}, .y: {y} }` = Point { .x = x, .y = \"\" };\n"
		# "}"

		# "namespace std { type i32 = signed int; }\n"
		# "fun i32_swap(let a: * mut std::i32, let b : * mut* std::i32) : void {\n"
		# "`({a@}, {b@})` = (b@, a@);\n"
		# "}"

		# "namespace std { type i32 = signed int; }\n"
		# "variant Option { None; Some : * mut byte; }\n"
		# "variant Outer { Double : (Option, Option); Single : Option; Empty; }\n"
		# "fun process(let c : * char) : void;\n"
		# "fun process2(let o : Option) : bool;\n"
		# "fun condition() : void;\n"
		# "fun error() : void;\n"
		# "fun main() : void {\n"
		# "\tlet get_inner = Double(None, Some(\"\" as * mut byte));\n"
		# "\t\tvariant LocalOption { None; }\n"
		# "\tmatch (get_inner) {\n"
		# "\t\tDouble (None, Some (st)) : process(st);\n"
		# "\t\tSingle (opt) if condition() : process2(opt);\n"
		# "\t\t_ : error();\n"
		# "\t}\n"
		# "}"

		# "struct _Temp { x: int; }\n"
		# "type Temp = _Temp;\n"
		# "fun main() : void {\n"
		# "\tstruct _Temp { x: int; }\n"
		# "\tlet Temp { mut .x } = _Temp { .x = 2 };"
		# "}"

		# /* OK */ "namespace std { type i32 = signed int; }\n"
		# "struct Point { x, y: std::i32; }\n"
		# "fun l_inf_norm(let Point { .x, .y } : Point, let Point { .x: x1, .y: y1 } : Point) : std::i32 {\n"
		# "\tlet abs = \\ (let i : std::i32) : std::i32 { return i < 0 ? -i : i; };\n"
		# "\tlet max = \\ (let x : std::i32, let y : std::i32) : std::i32 { return x < y ? y : x; };\n"
		# "\tlet xdiff = abs(x - x1), ydiff = abs(y - y1);\n"
		# "\treturn max(xdiff, ydiff);\n"
		# "}"

		# "union U { z: int; }\n variant V {}\ntype UU = U;\n"
		# "@[public] fun main() : void { let mut z : int; let UU { mut .z } = 2; }"

		# "variant Option { None; Some : * byte; }\n"
		# "fun divide(let n : unsigned int, let d : unsigned int) : Option {\n"
		# "\treturn d == 0 ? None : Some((n / d) as * mut byte);\n"
		# "}\n"
		# "fun main () : void {\n"
		# "\tlet (num, denom) = (7, 3);\n"
		# "\tlet Some() = divide(num, denom), rem = num - denom * quot;\n"
		# "}\n"

		# "variant Option { None; Some : * mut byte; }\n"
		# "fun divide(let n : unsigned int, let d : unsigned int) : Option {\n"
		# "\treturn d == 0 ? None : Some((n / d) as mut* byte);\n"
		# "}\n"
		# "fun main () : void {\n"
		# "\tlet (num, denom) = (7, 3);\n"
		# "\tlet Some() = divide(num, denom), rem = num - denom * quot;\n"
		# "}\n"

		# "variant Option { None; Some : * mut byte; }\n"
		# "fun divide(let n : unsigned int, let d : unsigned int) : Option {\n"
		# "\treturn d == 0 ? None : Some((n / d) as * mut byte);\n"
		# "}\n"
		# "fun main () : void {\n"
		# "\tlet (num, denom) = (7, 3);\n"
		# "\tlet Some(quot) = divide(num, denom), rem = num - denom * quot;\n"
		# "}\n"

		# "namespace std { type u32 = unsigned int; }\n"
		# "type u32 = mut * char;\n"
		# "namespace std { struct Point { x: u32; y: u32; } }\n"
		# "type Point = std::Point;\n"
		# "fun main() : void { /* using std::u32; */ let (mut a, b) : (u32, u32); let point = Point { .x = a, .y = b }; }\n"

		# "struct Point { x: int; y: int; }\n"
		# "fun test() : void { let point = Point{ .x = 2, .y = 4, .x = 3 }; }"

		# "fun main() : mut ((((*(((void))))))) {}"

		# /* OK */ "variant Option { None; Some : * mut byte; }\n"
		# "fun divide(let n : unsigned int, let d : unsigned int) : Option {\n"
		# "\treturn d == 0 ? None : Some((n / d) as * mut byte);\n"
		# "}\n"
		# "fun main () : void {\n"
		# "\tlet (num, denom) = (7, 3);\n"
		# "\tlet Some(quot -> float) = divide(num, denom), rem = num - denom * quot;\n"
		# "}\n"

		# "fun fabs(let a : float) : float { return a < 0 ? -a : a; }\n"
		# "fun rect_area(let (a, b) : (float, float), let (c, d) : (float, float)) : float {\n"
		# "\treturn fabs(c - a) * fabs(d - b);\n"
		# "}\n"
		# "fun main() : void {\n"
		# "\trect_area((1, true), (3, 4));\n"
		# "}\n"

		# /* OK */ "fun fabs(let a : float) : float { return a < 0 ? -a : a; }\n"
		# "fun rect_area(let (a, b) : (float, float), let (c, d) : (float, float)) : float {\n"
		# "\treturn fabs(c - a) * fabs(d - b);\n"
		# "}\n"
		# "fun main() : void {\n"
		# "\tlet t = (1, 2.0);\n"
		# "\trect_area(t, (3, 4));\n"
		# "}\n"

		# "struct Point { x: int; y: int; }\n"
		# "fun main() : void {\n"
		# "\tlet point = Point{ .x = 2, .y = -3 };\n"
		# "\tpoint = Point{ .x = 3 };\n"
		# "}\n"

		# /* OK */ "struct Point { x: int; y: float; }\n"
		# "fun main() : void {\n"
		# "\tlet point = Point{ .x = 2, .y = -3 };\n"
		# "\t(true ? point.x : point.y) = 2;\n"
		# "}\n"

		# /* OK */ "struct Point { x: int; y: int; }\n"
		# "fun main() : void {\n"
		# "\tlet point = Point{ .x = 2, .y = -3 };\n"
		# "\t(true ? point.x : point.y) = 2;\n"
		# "}\n"

		"type i32 = int, u8 = unsigned byte;\n"
		"fun main() : i32 {\n"
		"\t// let (mut s, (t, u)) = (2_s, (3, 4.0));\n"
		"\t// let (mut v, w) = (5_s, (6, 7.0));\n"
		"\tlet (d, (..., a, b), c, ..., e, _) = (9_s, ('0', 10, '2'), 6, 7, 8_s, true, (1, 2), (3, 4));\n"
		"}\n"
	);

	type lex::lexer* l = lex::lexer_init(f, 0, src);
	type parse::parser* p = parse::parser_init(l);
	type ast::prog* pr = parse::parse_prog(p);

	if (util::num_errors() != 0 || pr == NULL as type ast::prog*)
		return 1;

	ast::prog_print(pr, 0), printf("\n");
	type tck::symtab* global = tck::symtab_global_init();
	if (!tck::tck_prog(global, pr))
		return 1;

	type ir::ir_ctx* ic = ir::ir_ctx_init(global);
	type ir::prog* ipr = ir::ir_prog(ic, pr);
	if (ipr == NULL as type ir::prog*)
		return 1;

	if (util::ht_size(ic->name_2_aggregate) != 0) {
		type util::hash_table_iterator* iter = util::ht_iter_init(ic->name_2_aggregate);
		for (; !util::ht_iter_done(iter); util::ht_iter_advance(iter)) {
			type util::hash_table_entry* hte = util::ht_iter_curr(iter);

			ir::top_level_print(hte->value as type ir::top_level*), printf("\n");
		}
		util::ht_iter_delete(iter);

		printf("\n");
	}

	ir::prog_print(ipr);

	ir::ir_ctx_delete(ic);
	tck::symtab_delete(global);
	ast::prog_delete(pr);
	parse::parser_delete(p);

	return 0;
}