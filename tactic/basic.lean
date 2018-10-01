/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Simon Hudon, Scott Morrison
-/
import data.dlist.basic category.basic

namespace name

meta def deinternalize_field : name → name
| (name.mk_string s name.anonymous) :=
  let i := s.mk_iterator in
  if i.curr = '_' then i.next.next_to_string else s
| n := n

end name

namespace expr
open tactic

attribute [derive has_reflect] binder_info

protected meta def to_pos_nat : expr → option ℕ
| `(has_one.one _) := some 1
| `(bit0 %%e) := bit0 <$> e.to_pos_nat
| `(bit1 %%e) := bit1 <$> e.to_pos_nat
| _           := none

protected meta def to_nat : expr → option ℕ
| `(has_zero.zero _) := some 0
| e                  := e.to_pos_nat

protected meta def to_int : expr → option ℤ
| `(has_neg.neg %%e) := do n ← e.to_nat, some (-n)
| e                  := coe <$> e.to_nat

protected meta def of_nat (α : expr) : ℕ → tactic expr :=
nat.binary_rec
  (tactic.mk_mapp ``has_zero.zero [some α, none])
  (λ b n tac, if n = 0 then mk_mapp ``has_one.one [some α, none] else
    do e ← tac, tactic.mk_app (cond b ``bit1 ``bit0) [e])

protected meta def of_int (α : expr) : ℤ → tactic expr
| (n : ℕ) := expr.of_nat α n
| -[1+ n] := do
  e ← expr.of_nat α (n+1),
  tactic.mk_app ``has_neg.neg [e]

meta def is_meta_var : expr → bool
| (mvar _ _ _) := tt
| e            := ff

meta def is_sort : expr → bool
| (sort _) := tt
| e         := ff

meta def list_local_consts (e : expr) : list expr :=
e.fold [] (λ e' _ es, if e'.is_local_constant then insert e' es else es)

meta def list_meta_vars (e : expr) : list expr :=
e.fold [] (λ e' _ es, if e'.is_meta_var then insert e' es else es)

meta def list_names_with_prefix (pre : name) (e : expr) : name_set :=
e.fold mk_name_set $ λ e' _ l,
  match e' with
  | expr.const n _ := if n.get_prefix = pre then l.insert n else l
  | _ := l
  end

/- only traverses the direct descendents -/
meta def {u} traverse {m : Type → Type u} [applicative m]
  {elab elab' : bool} (f : expr elab → m (expr elab')) :
  expr elab → m (expr elab')
 | (var v)  := pure $ var v
 | (sort l) := pure $ sort l
 | (const n ls) := pure $ const n ls
 | (mvar n n' e) := mvar n n' <$> f e
 | (local_const n n' bi e) := local_const n n' bi <$> f e
 | (app e₀ e₁) := app <$> f e₀ <*> f e₁
 | (lam n bi e₀ e₁) := lam n bi <$> f e₀ <*> f e₁
 | (pi n bi e₀ e₁) := pi n bi <$> f e₀ <*> f e₁
 | (elet n e₀ e₁ e₂) := elet n <$> f e₀ <*> f e₁ <*> f e₂
 | (macro mac es) := macro mac <$> list.traverse f es

meta def mfoldl {α : Type} {m} [monad m] (f : α → expr → m α) : α → expr → m α
| x e := prod.snd <$> (state_t.run (e.traverse $ λ e',
    (get >>= monad_lift ∘ flip f e' >>= put) $> e') x : m _)

end expr

namespace environment

meta def in_current_file' (env : environment) (n : name) : bool :=
env.in_current_file n && (n ∉ [``quot, ``quot.mk, ``quot.lift, ``quot.ind])

meta def is_structure_like (env : environment) (n : name) : option (nat × name) :=
do guardb (env.is_inductive n),
  d ← (env.get n).to_option,
  [intro] ← pure (env.constructors_of n) | none,
  guard (env.inductive_num_indices n = 0),
  some (env.inductive_num_params n, intro)

meta def is_structure (env : environment) (n : name) : bool :=
option.is_some $ do
  (nparams, intro) ← env.is_structure_like n,
  di ← (env.get intro).to_option,
  expr.pi x _ _ _ ← nparams.iterate
    (λ e : option expr, do expr.pi _ _ _ body ← e | none, some body)
    (some di.type) | none,
  env.is_projection (n ++ x.deinternalize_field)

end environment

namespace interaction_monad
open result

meta def get_result {σ α} (tac : interaction_monad σ α) :
  interaction_monad σ (interaction_monad.result σ α) | s :=
match tac s with
| r@(success _ s') := success r s'
| r@(exception _ _ s') := success r s'
end

end interaction_monad

namespace lean.parser
open lean interaction_monad.result

meta def of_tactic' {α} (tac : tactic α) : parser α :=
do r ← of_tactic (interaction_monad.get_result tac),
match r with
| (success a _) := return a
| (exception f pos _) := exception f pos
end

end lean.parser

namespace tactic

meta def mk_local (n : name) : expr :=
expr.local_const n n binder_info.default (expr.const n [])

meta def local_def_value (e : expr) : tactic expr := do
do (v,_) ← solve_aux `(true) (do
         (expr.elet n t v _) ← (revert e >> target)
           | fail format!"{e} is not a local definition",
         return v),
   return v

meta def check_defn (n : name) (e : pexpr) : tactic unit :=
do (declaration.defn _ _ _ d _ _) ← get_decl n,
   e' ← to_expr e,
   guard (d =ₐ e') <|> trace d >> failed

-- meta def compile_eqn (n : name) (univ : list name) (args : list expr) (val : expr) (num : ℕ) : tactic unit :=
-- do let lhs := (expr.const n $ univ.map level.param).mk_app args,
--    stmt ← mk_app `eq [lhs,val],
--    let vs := stmt.list_local_const,
--    let stmt := stmt.pis vs,
--    (_,pr) ← solve_aux stmt (tactic.intros >> reflexivity),
--    add_decl $ declaration.thm (n <.> "equations" <.> to_string (format!"_eqn_{num}")) univ stmt (pure pr)

meta def to_implicit : expr → expr
| (expr.local_const uniq n bi t) := expr.local_const uniq n binder_info.implicit t
| e := e

meta def pis : list expr → expr → tactic expr
| (e@(expr.local_const uniq pp info _) :: es) f := do
  t ← infer_type e,
  f' ← pis es f,
  pure $ expr.pi pp info t (expr.abstract_local f' uniq)
| _ f := pure f

meta def lambdas : list expr → expr → tactic expr
| (e@(expr.local_const uniq pp info _) :: es) f := do
  t ← infer_type e,
  f' ← lambdas es f,
  pure $ expr.lam pp info t (expr.abstract_local f' uniq)
| _ f := pure f

meta def extract_def (n : name) (trusted : bool) (elab_def : tactic unit) : tactic unit :=
do cxt ← list.map to_implicit <$> local_context,
   t ← target,
   (eqns,d) ← solve_aux t elab_def,
   d ← instantiate_mvars d,
   t' ← pis cxt t,
   d' ← lambdas cxt d,
   let univ := t'.collect_univ_params,
   add_decl $ declaration.defn n univ t' d' (reducibility_hints.regular 1 tt) trusted,
   applyc n

meta def exact_dec_trivial : tactic unit := `[exact dec_trivial]

/-- Runs a tactic for a result, reverting the state after completion -/
meta def retrieve {α} (tac : tactic α) : tactic α :=
λ s, result.cases_on (tac s)
 (λ a s', result.success a s)
 result.exception

/-- Repeat a tactic at least once, calling it recursively on all subgoals,
  until it fails. This tactic fails if the first invocation fails. -/
meta def repeat1 (t : tactic unit) : tactic unit := t; repeat t

/-- `iterate_range m n t`: Repeat the given tactic at least `m` times and
  at most `n` times or until `t` fails. Fails if `t` does not run at least m times. -/
meta def iterate_range : ℕ → ℕ → tactic unit → tactic unit
| 0 0     t := skip
| 0 (n+1) t := try (t >> iterate_range 0 n t)
| (m+1) n t := t >> iterate_range m (n-1) t

meta def replace_at (tac : expr → tactic (expr × expr)) (hs : list expr) (tgt : bool) : tactic bool :=
do to_remove ← hs.mfilter $ λ h, do {
    h_type ← infer_type h,
    succeeds $ do
      (new_h_type, pr) ← tac h_type,
      assert h.local_pp_name new_h_type,
      mk_eq_mp pr h >>= tactic.exact },
  goal_simplified ← succeeds $ do {
    guard tgt,
    (new_t, pr) ← target >>= tac,
    replace_target new_t pr },
  to_remove.mmap' (λ h, try (clear h)),
  return (¬ to_remove.empty ∨ goal_simplified)

meta def simp_bottom_up' (post : expr → tactic (expr × expr)) (e : expr) (cfg : simp_config := {}) : tactic (expr × expr) :=
prod.snd <$> simplify_bottom_up () (λ _, (<$>) (prod.mk ()) ∘ post) e cfg

meta structure instance_cache :=
(α : expr)
(univ : level)
(inst : name_map expr)

meta def mk_instance_cache (α : expr) : tactic instance_cache :=
do u ← mk_meta_univ,
   infer_type α >>= unify (expr.sort (level.succ u)),
   u ← get_univ_assignment u,
   return ⟨α, u, mk_name_map⟩

namespace instance_cache

meta def get (c : instance_cache) (n : name) : tactic (instance_cache × expr) :=
match c.inst.find n with
| some i := return (c, i)
| none := do e ← mk_app n [c.α] >>= mk_instance,
  return (⟨c.α, c.univ, c.inst.insert n e⟩, e)
end

open expr
meta def append_typeclasses : expr → instance_cache → list expr →
  tactic (instance_cache × list expr)
| (pi _ binder_info.inst_implicit (app (const n _) (var _)) body) c l :=
  do (c, p) ← c.get n, return (c, p :: l)
| _ c l := return (c, l)

meta def mk_app (c : instance_cache) (n : name) (l : list expr) : tactic (instance_cache × expr) :=
do d ← get_decl n,
   (c, l) ← append_typeclasses d.type.binding_body c l,
   return (c, (expr.const n [c.univ]).mk_app (c.α :: l))

end instance_cache

/-- Reset the instance cache for the main goal. -/
meta def reset_instance_cache : tactic unit := unfreeze_local_instances

meta def match_head (e : expr) : expr → tactic unit
| e' :=
    unify e e'
<|> do `(_ → %%e') ← whnf e',
       v ← mk_mvar,
       match_head (e'.instantiate_var v)

meta def find_matching_head : expr → list expr → tactic (list expr)
| e []         := return []
| e (H :: Hs) :=
  do t ← infer_type H,
     ((::) H <$ match_head e t <|> pure id) <*> find_matching_head e Hs

meta def subst_locals (s : list (expr × expr)) (e : expr) : expr :=
(e.abstract_locals (s.map (expr.local_uniq_name ∘ prod.fst)).reverse).instantiate_vars (s.map prod.snd)

meta def set_binder : expr → list binder_info → expr
| e [] := e
| (expr.pi v _ d b) (bi :: bs) := expr.pi v bi d (set_binder b bs)
| e _ := e

meta def last_explicit_arg : expr → tactic expr
| (expr.app f e) :=
do t ← infer_type f >>= whnf,
   if t.binding_info = binder_info.default
     then pure e
     else last_explicit_arg f
| e := pure e

private meta def get_expl_pi_arity_aux : expr → tactic nat
| (expr.pi n bi d b) :=
  do m     ← mk_fresh_name,
     let l := expr.local_const m n bi d,
     new_b ← whnf (expr.instantiate_var b l),
     r     ← get_expl_pi_arity_aux new_b,
     if bi = binder_info.default then
       return (r + 1)
     else
       return r
| e := return 0

/-- Compute the arity of explicit arguments of the given (Pi-)type -/
meta def get_expl_pi_arity (type : expr) : tactic nat :=
whnf type >>= get_expl_pi_arity_aux

/-- Compute the arity of explicit arguments of the given function -/
meta def get_expl_arity (fn : expr) : tactic nat :=
infer_type fn >>= get_expl_pi_arity

/-- variation on `assert` where a (possibly incomplete)
    proof of the assertion is provided as a parameter.

    ``(h,gs) ← local_proof `h p tac`` creates a local `h : p` and
    use `tac` to (partially) construct a proof for it. `gs` is the
    list of remaining goals in the proof of `h`.

    The benefits over assert are:
    - unlike with ``h ← assert `h p, tac`` , `h` cannot be used by `tac`;
    - when `tac` does not complete the proof of `h`, returning the list
      of goals allows one to write a tactic using `h` and with the confidence
      that a proof will not boil over to goals left over from the proof of `h`,
      unlike what would be the case when using `tactic.swap`.
-/
meta def local_proof (h : name) (p : expr) (tac₀ : tactic unit) :
  tactic (expr × list expr) :=
focus1 $
do h' ← assert h p,
   [g₀,g₁] ← get_goals,
   set_goals [g₀], tac₀,
   gs ← get_goals,
   set_goals [g₁],
   return (h', gs)

meta def var_names : expr → list name
| (expr.pi n _ _ b) := n :: var_names b
| _ := []

meta def drop_binders : expr → tactic expr
| (expr.pi n bi t b) := b.instantiate_var <$> mk_local' n bi t >>= drop_binders
| e := pure e

meta def subobject_names (struct_n : name) : tactic (list name × list name) :=
do env ← get_env,
   [c] ← pure $ env.constructors_of struct_n | fail "too many constructors",
   vs  ← var_names <$> (mk_const c >>= infer_type),
   fields ← env.structure_fields struct_n,
   return $ fields.partition (λ fn, ↑("_" ++ fn.to_string) ∈ vs)

meta def expanded_field_list' : name → tactic (dlist $ name × name) | struct_n :=
do (so,fs) ← subobject_names struct_n,
   ts ← so.mmap (λ n, do
     e ← mk_const (n.update_prefix struct_n) >>= infer_type >>= drop_binders,
     expanded_field_list' $ e.get_app_fn.const_name),
   return $ dlist.join ts ++ dlist.of_list (fs.map $ prod.mk struct_n)
open functor function

meta def expanded_field_list (struct_n : name) : tactic (list $ name × name) :=
dlist.to_list <$> expanded_field_list' struct_n

meta def get_classes (e : expr) : tactic (list name) :=
attribute.get_instances `class >>= list.mfilter (λ n,
  succeeds $ mk_app n [e] >>= mk_instance)

open nat

meta def mk_mvar_list : ℕ → tactic (list expr)
| 0 := pure []
| (succ n) := (::) <$> mk_mvar <*> mk_mvar_list n

/--`iterate_at_most_on_all_goals n t`: repeat the given tactic at most `n` times on all goals,
or until it fails. Always succeeds. -/
meta def iterate_at_most_on_all_goals : nat → tactic unit → tactic unit
| 0        tac := trace "maximal iterations reached"
| (succ n) tac := tactic.all_goals $ (do tac, iterate_at_most_on_all_goals n tac) <|> skip

/--`iterate_at_most_on_subgoals n t`: repeat the tactic `t` at most `n` times on the first
goal and on all subgoals thus produced, or until it fails. Fails iff `t` fails on
current goal. -/
meta def iterate_at_most_on_subgoals : nat → tactic unit → tactic unit
| 0        tac := trace "maximal iterations reached"
| (succ n) tac := focus1 (do tac, iterate_at_most_on_all_goals n tac)

/--`apply_list l`: try to apply the tactics in the list `l` on the first goal, and
fail if none succeeds -/
meta def apply_list_expr : list expr → tactic unit
| []     := fail "no matching rule"
| (h::t) := do interactive.concat_tags (apply h) <|> apply_list_expr t

/-- constructs a list of expressions given a list of p-expressions, as follows:
- if the p-expression is the name of a theorem, use `i_to_expr_for_apply` on it
- if the p-expression is a user attribute, add all the theorems with this attribute
  to the list.-/
meta def build_list_expr_for_apply : list pexpr → tactic (list expr)
| [] := return []
| (h::t) := do
  tail ← build_list_expr_for_apply t,
  a ← i_to_expr_for_apply h,
  (do l ← attribute.get_instances (expr.const_name a),
      m ← list.mmap mk_const l,
      return (m.append tail))
  <|> return (a::tail)

/--`apply_rules hs n`: apply the list of rules `hs` (given as pexpr) and `assumption` on the
first goal and the resulting subgoals, iteratively, at most `n` times -/
meta def apply_rules (hs : list pexpr) (n : nat) : tactic unit :=
do l ← build_list_expr_for_apply hs,
   iterate_at_most_on_subgoals n (assumption <|> apply_list_expr l)

meta def replace (h : name) (p : pexpr) : tactic unit :=
do h' ← get_local h,
   p ← to_expr p,
   note h none p,
   clear h'

meta def symm_apply (e : expr) (cfg : apply_cfg := {}) : tactic (list (name × expr)) :=
tactic.apply e cfg <|> (symmetry >> tactic.apply e cfg)

meta def apply_assumption
  (asms : tactic (list expr) := local_context)
  (tac : tactic unit := skip) : tactic unit :=
do { ctx ← asms,
     ctx.any_of (λ H, () <$ symm_apply H; tac) } <|>
do { exfalso,
     ctx ← asms,
     ctx.any_of (λ H, () <$ symm_apply H; tac) }
<|> fail "assumption tactic failed"

open nat

meta def solve_by_elim_aux (discharger : tactic unit) (asms : tactic (list expr))  : ℕ → tactic unit
| 0 := done
| (succ n) := discharger <|> (apply_assumption asms $ solve_by_elim_aux n)

meta structure by_elim_opt :=
  (discharger : tactic unit := done)
  (assumptions : tactic (list expr) := local_context)
  (max_rep : ℕ := 3)

meta def solve_by_elim (opt : by_elim_opt := { }) : tactic unit :=
do
  tactic.fail_if_no_goals,
  solve_by_elim_aux opt.discharger opt.assumptions opt.max_rep

meta def metavariables : tactic (list expr) :=
do r ← result,
   pure (r.list_meta_vars)

/-- Succeeds only if the current goal is a proposition. -/
meta def propositional_goal : tactic unit :=
do goals ← get_goals,
   let current_goal := goals.head,
   current_goal_type ← infer_type current_goal,
   p ← is_prop current_goal_type,
   guard p

variable {α : Type}

private meta def iterate_aux (t : tactic α) : list α → tactic (list α)
| L := (do r ← t, iterate_aux (r :: L)) <|> return L

meta def iterate' (t : tactic α) : tactic (list α) :=
list.reverse <$> iterate_aux t []

meta def iterate1 (t : tactic α) : tactic (α × list α) :=
do r ← t | fail "iterate1 failed: tactic did not succeed",
   L ← iterate' t,
   return (r, L)

meta def intros1 : tactic (list expr) :=
iterate1 intro1 >>= λ p, return (p.1 :: p.2)

/-- `successes` invokes each tactic in turn, returning the list of successful results. -/
meta def successes {α} (tactics : list (tactic α)) : tactic (list α) :=
list.filter_map id <$> monad.sequence (tactics.map (λ t, try_core t))

/-- Return target after instantiating metavars and whnf -/
private meta def target' : tactic expr :=
target >>= instantiate_mvars >>= whnf

/--
Just like `split`, `fsplit` applies the constructor when the type of the target is an inductive data type with one constructor.
However it does not reorder goals or invoke `auto_param` tactics.
-/
-- FIXME check if we can remove `auto_param := ff`
meta def fsplit : tactic unit :=
do [c] ← target' >>= get_constructors_for | tactic.fail "fsplit tactic failed, target is not an inductive datatype with only one constructor",
   mk_const c >>= λ e, apply e {new_goals := new_goals.all, auto_param := ff} >> skip

run_cmd add_interactive [`fsplit]

/-- Calls `injection` on each hypothesis, and then, for each hypothesis on which `injection`
    succeeds, clears the old hypothesis. -/
meta def injections_and_clear : tactic unit :=
do l ← local_context,
   results ← successes $ l.map $ λ e, injection e >> clear e,
   when (results.empty) (fail "could not use `injection` then `clear` on any hypothesis")

run_cmd add_interactive [`injections_and_clear]

meta def note_anon (e : expr) : tactic unit :=
do n ← get_unused_name "lh",
   note n none e, skip

meta def find_local (t : pexpr) : tactic expr :=
do t' ← to_expr t,
   prod.snd <$> solve_aux t' assumption

end tactic
