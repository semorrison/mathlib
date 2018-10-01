/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Scott Morrison
-/
import tactic data.set.lattice data.prod
       tactic.rewrite data.stream.basic

section solve_by_elim
example {a b : Prop} (h₀ : a → b) (h₁ : a) : b :=
begin
  apply_assumption,
  apply_assumption,
end

example {a b : Prop} (h₀ : a → b) (h₁ : a) : b :=
by solve_by_elim

example {α : Type} {a b : α → Prop} (h₀ : ∀ x : α, b x = a x) (y : α) : a y = b y :=
by solve_by_elim

example {α : Type} {a b : α → Prop} (h₀ : b = a) (y : α) : a y = b y :=
by solve_by_elim

example {α : Type} {a b : α → Prop} (h₀ : b = a) (y : α) : a y = b y :=
begin
  success_if_fail { solve_by_elim only [] },
  success_if_fail { solve_by_elim only [h₀] },
  solve_by_elim only [h₀, congr_fun]
end

example {α : Type} {a b : α → Prop} (h₀ : b = a) (y : α) : a y = b y :=
by solve_by_elim [h₀]

example {α : Type} {a b : α → Prop} (h₀ : b = a) (y : α) : a y = b y :=
begin
 success_if_fail { solve_by_elim [*, -h₀] },
 solve_by_elim [*]
end

example {α β : Type} (a b : α) (f : α → β) (i : function.injective f) (h : f a = f b) : a = b :=
begin
  success_if_fail { solve_by_elim only [i] },
  success_if_fail { solve_by_elim only [h] },
  solve_by_elim only [i,h]
end

@[user_attribute]
meta def ex : user_attribute := {
  name := `ex,
  descr := "An example attribute for testing solve_by_elim."
}

@[ex] def f : ℕ := 0

example : ℕ := by solve_by_elim [f]

example : ℕ :=
begin
  success_if_fail { solve_by_elim },
  success_if_fail { solve_by_elim [ex, -f] },
  solve_by_elim [ex],
end

example {α : Type} {p : α → Prop} (h₀ : ∀ x, p x) (y : α) : p y :=
begin
  apply_assumption,
end

open tactic

example : true :=
begin
  (do gs ← get_goals,
     set_goals [],
     success_if_fail `[solve_by_elim],
     set_goals gs),
  trivial
end

end solve_by_elim

section tauto₀
variables p q r : Prop
variables h : p ∧ q ∨ p ∧ r
include h
example : p ∧ p :=
by tauto

end tauto₀

section tauto₁
variables α : Type
variables p q r : α → Prop
variables h : (∃ x, p x ∧ q x) ∨ (∃ x, p x ∧ r x)
include h
example : ∃ x, p x :=
by tauto

end tauto₁

section tauto₂
variables α : Type
variables x : α
variables p q r : α → Prop
variables h₀ : (∀ x, p x → q x → r x) ∨ r x
variables h₁ : p x
variables h₂ : q x

include h₀ h₁ h₂
example : ∃ x, r x :=
by tauto

end tauto₂

section tauto₃


example (p : Prop) : p ∧ true ↔ p := by tauto
example (p : Prop) : p ∨ false ↔ p := by tauto
example (p q r : Prop) [decidable p] [decidable r] : p ∨ (q ∧ r) ↔ (p ∨ q) ∧ (r ∨ p ∨ r) := by tauto
example (p q r : Prop) [decidable q] [decidable r] : p ∨ (q ∧ r) ↔ (p ∨ q) ∧ (r ∨ p ∨ r) := by tauto
example (p q : Prop) [decidable q] [decidable p] (h : ¬ (p ↔ q)) (h' : ¬ p) : q := by tauto
example (p q : Prop) [decidable q] [decidable p] (h : ¬ (p ↔ q)) (h' : p) : ¬ q := by tauto
example (p q : Prop) [decidable q] [decidable p] (h : ¬ (p ↔ q)) (h' : q) : ¬ p := by tauto
example (p q : Prop) [decidable q] [decidable p] (h : ¬ (p ↔ q)) (h' : ¬ q) : p := by tauto
example (p q : Prop) [decidable q] [decidable p] (h : ¬ (p ↔ q)) (h' : ¬ q) (h'' : ¬ p) : false := by tauto
example (p q r : Prop) [decidable q] [decidable p] (h : p ↔ q) (h' : r ↔ q) (h'' : ¬ r) : ¬ p := by tauto
example (p q r : Prop) [decidable q] [decidable p] (h : p ↔ q) (h' : r ↔ q) : p ↔ r :=
by tauto
example (p q r : Prop) [decidable p] [decidable q] [decidable r] (h : ¬ p = q) (h' : r = q) : p ↔ ¬ r := by tauto

section modulo_symmetry
variables {p q r : Prop} {α : Type} {x y : α} [decidable_eq α]
variables [decidable p] [decidable q] [decidable r]
variables (h : x = y)
variables (h'' : (p ∧ q ↔ q ∨ r) ↔ (r ∧ p ↔ r ∨ q))
include h
include h''
example (h' : ¬ y = x) : p ∧ q := by tauto
example (h' : p ∧ ¬ y = x) : p ∧ q := by tauto
example : y = x := by tauto
example (h' : ¬ x = y) : p ∧ q := by tauto
example : x = y := by tauto

end modulo_symmetry

end tauto₃

section wlog

example {x y : ℕ} (a : x = 1) : true :=
begin
  suffices : false, trivial,
  wlog h : x = y,
  { guard_target x = y ∨ y = x,
    admit },
  { guard_hyp h := x = y,
    guard_hyp a := x = 1,
    admit }
end

example {x y : ℕ} : true :=
begin
  suffices : false, trivial,
  wlog h : x ≤ y,
  { guard_hyp h := x ≤ y,
    guard_target false,
    admit }
end

example {x y z : ℕ} : true :=
begin
  suffices : false, trivial,
  wlog : x ≤ y + z using x y,
  { guard_target x ≤ y + z ∨ y ≤ x + z,
    admit },
  { guard_hyp case := x ≤ y + z,
    guard_target false,
    admit },
end

example {x : ℕ} (S₀ S₁ : set ℕ) (P : ℕ → Prop)
  (h : x ∈ S₀ ∪ S₁) : true :=
begin
  suffices : false, trivial,
  wlog h' : x ∈ S₀ using S₀ S₁,
  { guard_target x ∈ S₀ ∨ x ∈ S₁,
    admit },
  { guard_hyp h  := x ∈ S₀ ∪ S₁,
    guard_hyp h' := x ∈ S₀,
    admit }
end

example {n m i : ℕ} {p : ℕ → ℕ → ℕ → Prop} : true :=
begin
  suffices : false, trivial,
  wlog : p n m i using [n m i, n i m, i n m],
  { guard_target p n m i ∨ p n i m ∨ p i n m,
    admit },
  { guard_hyp case := p n m i,
    admit }
end

example {n m i : ℕ} {p : ℕ → Prop} : true :=
begin
  suffices : false, trivial,
  wlog : p n using [n m i, m n i, i n m],
  { guard_target p n ∨ p m ∨ p i,
    admit },
  { guard_hyp case := p n,
    admit }
end

example {n m i : ℕ} {p : ℕ → ℕ → Prop} {q : ℕ → ℕ → ℕ → Prop} : true :=
begin
  suffices : q n m i, trivial,
  have h : p n i ∨ p i m ∨ p m i, from sorry,
  wlog : p n i := h using n m i,
  { guard_hyp h := p n i,
    guard_target q n m i,
    admit },
  { guard_hyp h := p i m,
    guard_hyp this := q i m n,
    guard_target q n m i,
    admit },
  { guard_hyp h := p m i,
    guard_hyp this := q m i n,
    guard_target q n m i,
    admit },
end

example (X : Type) (A B C : set X) : A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) :=
begin
  ext x,
  split,
  { intro hyp,
    cases hyp,
    wlog x_in : x ∈ B using B C,
    { assumption },
    { exact or.inl ⟨hyp_left, x_in⟩ } },
  { intro hyp,
    wlog x_in : x ∈ A ∩ B using B C,
    { assumption },
    { exact ⟨x_in.left, or.inl x_in.right⟩ } }
end

example (X : Type) (A B C : set X) : A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) :=
begin
  ext x,
  split,
  { intro hyp,
    wlog x_in : x ∈ B := hyp.2 using B C,
    { exact or.inl ⟨hyp.1, x_in⟩ } },
  { intro hyp,
    wlog x_in : x ∈ A ∩ B := hyp using B C,
    { exact ⟨x_in.left, or.inl x_in.right⟩ } }
end

example (X : Type) (A B C : set X) : A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) :=
begin
  ext x,
  split,
  { intro hyp,
    cases hyp,
    wlog x_in : x ∈ B := hyp_right using B C,
    { exact or.inl ⟨hyp_left, x_in⟩ }, },
  { intro hyp,
    wlog x_in : x ∈ A ∩ B := hyp using B C,
    { exact ⟨x_in.left, or.inl x_in.right⟩ } }
end

end wlog

example (m n p q : nat) (h : m + n = p) : true :=
begin
  have : m + n = q,
  { generalize_hyp h' : m + n = x at h,
    guard_hyp h' := m + n = x,
    guard_hyp h := x = p,
    guard_target m + n = q,
    admit },
  have : m + n = q,
  { generalize_hyp h' : m + n = x at h ⊢,
    guard_hyp h' := m + n = x,
    guard_hyp h := x = p,
    guard_target x = q,
    admit },
  trivial
end

example (α : Sort*) (L₁ L₂ L₃ : list α)
  (H : L₁ ++ L₂ = L₃) : true :=
begin
  have : L₁ ++ L₂ = L₂,
  { generalize_hyp h : L₁ ++ L₂ = L at H,
    induction L with hd tl ih,
    case list.nil
    { tactic.cleanup,
      change list.nil = L₃ at H,
      admit },
    case list.cons
    { change hd :: tl = L₃ at H,
      admit } },
  trivial
end

section convert
open set

variables {α β : Type}
local attribute [simp]
private lemma singleton_inter_singleton_eq_empty {x y : α} :
  ({x} ∩ {y} = (∅ : set α)) ↔ x ≠ y :=
by simp [singleton_inter_eq_empty]

example {f : β → α} {x y : α} (h : x ≠ y) : f ⁻¹' {x} ∩ f ⁻¹' {y} = ∅ :=
begin
  have : {x} ∩ {y} = (∅ : set α) := by simpa using h,
  convert preimage_empty,
  rw [←preimage_inter,this],
end

end convert

section rcases

universe u
variables {α β γ : Type u}

example (x : α × β × γ) : true :=
begin
  rcases x with ⟨a, b, c⟩,
  { guard_hyp a := α,
    guard_hyp b := β,
    guard_hyp c := γ,
    trivial }
end

example (x : α × β × γ) : true :=
begin
  rcases x with ⟨a, ⟨b, c⟩⟩,
  { guard_hyp a := α,
    guard_hyp b := β,
    guard_hyp c := γ,
    trivial }
end

example (x : (α × β) × γ) : true :=
begin
  rcases x with ⟨⟨a, b⟩, c⟩,
  { guard_hyp a := α,
    guard_hyp b := β,
    guard_hyp c := γ,
    trivial }
end

example (x : inhabited α × option β ⊕ γ) : true :=
begin
  rcases x with ⟨⟨a⟩, _ | b⟩ | c,
  { guard_hyp a := α, trivial },
  { guard_hyp a := α, guard_hyp b := β, trivial },
  { guard_hyp c := γ, trivial }
end

example (x y : ℕ) (h : x = y) : true :=
begin
  rcases x with _|⟨⟩|z,
  { guard_hyp h := nat.zero = y, trivial },
  { guard_hyp h := nat.succ nat.zero = y, trivial },
  { guard_hyp z := ℕ,
    guard_hyp h := z.succ.succ = y, trivial },
end

-- from equiv.sum_empty
example (s : α ⊕ empty) : true :=
begin
  rcases s with _ | ⟨⟨⟩⟩,
  { guard_hyp s := α, trivial }
end

end rcases

section ext

@[extensionality] lemma unit.ext (x y : unit) : x = y :=
begin
  cases x, cases y, refl
end

example : subsingleton unit :=
begin
  split, intros, ext
end

example (x y : ℕ) : true :=
begin
  have : x = y,
  { ext <|> admit },
  have : x = y,
  { ext i <|> admit },
  have : x = y,
  { ext : 1 <|> admit },
  trivial
end

example (X Y : ℕ × ℕ)  (h : X.1 = Y.1) (h : X.2 = Y.2) : X = Y :=
begin
  ext; assumption
end

example (X Y : (ℕ → ℕ) × ℕ)  (h : ∀ i, X.1 i = Y.1 i) (h : X.2 = Y.2) : X = Y :=
begin
  ext x; solve_by_elim,
end

example (X Y : ℕ → ℕ × ℕ)  (h : ∀ i, X i = Y i) : true :=
begin
  have : X = Y,
  { ext i : 1,
    guard_target X i = Y i,
    admit },
  have : X = Y,
  { ext i,
    guard_target (X i).fst = (Y i).fst, admit,
    guard_target (X i).snd = (Y i).snd, admit, },
  have : X = Y,
  { ext : 1,
    guard_target X x = Y x,
    admit },
  trivial,
end

example (s₀ s₁ : set ℕ) (h : s₁ = s₀) : s₀ = s₁ :=
by { ext1, guard_target x ∈ s₀ ↔ x ∈ s₁, simp * }

example (s₀ s₁ : stream ℕ) (h : s₁ = s₀) : s₀ = s₁ :=
by { ext1, guard_target s₀.nth n = s₁.nth n, simp * }

example (s₀ s₁ : ℤ → set (ℕ × ℕ))
        (h : ∀ i a b, (a,b) ∈ s₀ i ↔ (a,b) ∈ s₁ i) : s₀ = s₁ :=
begin
  ext i ⟨a,b⟩,
  apply h
end

def my_foo {α} (x : semigroup α) (y : group α) : true := trivial

example {α : Type} : true :=
begin
  have : true,
  { refine_struct (@my_foo α { .. } { .. } ),
      -- 9 goals
    guard_tags _field mul semigroup, admit,
      -- case semigroup, mul
      -- α : Type
      -- ⊢ α → α → α

    guard_tags _field mul_assoc semigroup, admit,
      -- case semigroup, mul_assoc
      -- α : Type
      -- ⊢ ∀ (a b c : α), a * b * c = a * (b * c)

    guard_tags _field mul group, admit,
      -- case group, mul
      -- α : Type
      -- ⊢ α → α → α

    guard_tags _field mul_assoc group, admit,
      -- case group, mul_assoc
      -- α : Type
      -- ⊢ ∀ (a b c : α), a * b * c = a * (b * c)

    guard_tags _field one group, admit,
      -- case group, one
      -- α : Type
      -- ⊢ α

    guard_tags _field one_mul group, admit,
      -- case group, one_mul
      -- α : Type
      -- ⊢ ∀ (a : α), 1 * a = a

    guard_tags _field mul_one group, admit,
      -- case group, mul_one
      -- α : Type
      -- ⊢ ∀ (a : α), a * 1 = a

    guard_tags _field inv group, admit,
      -- case group, inv
      -- α : Type
      -- ⊢ α → α

    guard_tags _field mul_left_inv group, admit,
      -- case group, mul_left_inv
      -- α : Type
      -- ⊢ ∀ (a : α), a⁻¹ * a = 1
  },
  trivial
end

def my_bar {α} (x : semigroup α) (y : group α) (i j : α) : α := i

example {α : Type} : true :=
begin
  have : monoid α,
  { refine_struct { mul := my_bar { .. } { .. } },
    guard_tags _field mul semigroup, admit,
    guard_tags _field mul_assoc semigroup, admit,
    guard_tags _field mul group, admit,
    guard_tags _field mul_assoc group, admit,
    guard_tags _field one group, admit,
    guard_tags _field one_mul group, admit,
    guard_tags _field mul_one group, admit,
    guard_tags _field inv group, admit,
    guard_tags _field mul_left_inv group, admit,
    guard_tags _field mul_assoc monoid, admit,
    guard_tags _field one monoid, admit,
    guard_tags _field one_mul monoid, admit,
    guard_tags _field mul_one monoid, admit, },
  trivial
end

end ext

section apply_rules

example {a b c d e : nat} (h1 : a ≤ b) (h2 : c ≤ d) (h3 : 0 ≤ e) :
a + c * e + a + c + 0 ≤ b + d * e + b + d + e :=
add_le_add (add_le_add (add_le_add (add_le_add h1 (mul_le_mul_of_nonneg_right h2 h3)) h1 ) h2) h3

example {a b c d e : nat} (h1 : a ≤ b) (h2 : c ≤ d) (h3 : 0 ≤ e) :
a + c * e + a + c + 0 ≤ b + d * e + b + d + e :=
by apply_rules [add_le_add, mul_le_mul_of_nonneg_right]

@[user_attribute]
meta def mono_rules : user_attribute :=
{ name := `mono_rules,
  descr := "lemmas usable to prove monotonicity" }
attribute [mono_rules] add_le_add mul_le_mul_of_nonneg_right

example {a b c d e : nat} (h1 : a ≤ b) (h2 : c ≤ d) (h3 : 0 ≤ e) :
a + c * e + a + c + 0 ≤ b + d * e + b + d + e :=
by apply_rules [mono_rules]

example {a b c d e : nat} (h1 : a ≤ b) (h2 : c ≤ d) (h3 : 0 ≤ e) :
a + c * e + a + c + 0 ≤ b + d * e + b + d + e :=
by apply_rules mono_rules

end apply_rules

section h_generalize

variables {α β γ φ ψ : Type} (f : α → α → α → φ → γ)
          (x y : α) (a b : β) (z : φ)
          (h₀ : β = α) (h₁ : β = α) (h₂ : φ = β)
          (hx : x == a) (hy : y == b) (hz : z == a)
include f x y z a b hx hy hz

example : f x y x z = f (eq.rec_on h₀ a) (cast h₀ b) (eq.mpr h₁.symm a) (eq.mpr h₂ a) :=
begin
  guard_hyp_nums 16,
  h_generalize hp : a == p with hh,
  guard_hyp_nums 19,
  guard_hyp' hh := β = α,
  guard_target f x y x z = f p (cast h₀ b) p (eq.mpr h₂ a),
  h_generalize hq : _ == q,
  guard_hyp_nums 21,
  guard_target f x y x z = f p q p (eq.mpr h₂ a),
  h_generalize _ : _ == r,
  guard_hyp_nums 23,
  guard_target f x y x z = f p q p r,
  casesm* [_ == _, _ = _], refl
end

end h_generalize

section h_generalize

variables {α β γ φ ψ : Type} (f : list α → list α → γ)
          (x : list α) (a : list β) (z : φ)
          (h₀ : β = α) (h₁ : list β = list α)
          (hx : x == a)
include f x z a hx h₀ h₁

example : true :=
begin
  have : f x x = f (eq.rec_on h₀ a) (cast h₁ a),
  { guard_hyp_nums 11,
    h_generalize : a == p with _,
    guard_hyp_nums 13,
    guard_hyp' h := β = α,
    guard_target f x x = f p (cast h₁ a),
    h_generalize! : a == q ,
    guard_hyp_nums 13,
    guard_target ∀ q, f x x = f p q,
    casesm* [_ == _, _ = _],
    success_if_fail { refl },
    admit },
  trivial
end

end h_generalize

section assoc_rw
open tactic
example : ∀ x y z a b c : ℕ, true :=
begin
 intros,
 have : x + (y + z) = 3 + y, admit,
 have : a + (b + x) + y + (z + b + c) ≤ 0,
 (do this ← get_local `this,
     tgt ← to_expr ```(a + (b + x) + y + (z + b + c)),
     assoc ← mk_mapp ``add_monoid.add_assoc [`(ℕ),none],
     (l,p) ← assoc_rewrite_intl assoc this tgt,
     note `h none p  ),
 erw h,
 guard_target a + b + 3 + y + b + c ≤ 0,
 admit,
 trivial
end

example : ∀ x y z a b c : ℕ, true :=
begin
 intros,
 have : ∀ y, x + (y + z) = 3 + y, admit,
 have : a + (b + x) + y + (z + b + c) ≤ 0,
 (do this ← get_local `this,
     tgt ← to_expr ```(a + (b + x) + y + (z + b + c)),
     assoc_rewrite_target this ),
 guard_target a + b + 3 + y + b + c ≤ 0,
 admit,
 trivial
end

variables x y z a b c : ℕ
variables h₀ : ∀ (y : ℕ), x + (y + z) = 3 + y
variables h₁ : a + (b + x) + y + (z + b + a) ≤ 0
variables h₂ : y + b + c = y + b + a
include h₀ h₁ h₂
example : a + (b + x) + y + (z + b + c) ≤ 0 :=
by { assoc_rw [h₀,h₂] at *,
     guard_hyp _inst := is_associative ℕ has_add.add,
       -- keep a local instance of is_associative to cache
       -- type class queries
     exact h₁ }

end assoc_rw
