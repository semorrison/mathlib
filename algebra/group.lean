/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura

Various multiplicative and additive structures.
-/
import tactic.interactive data.option

section pending_1857

/- Transport multiplicative to additive -/
section transport
open tactic

@[user_attribute]
meta def to_additive_attr : user_attribute (name_map name) name :=
{ name      := `to_additive,
  descr     := "Transport multiplicative to additive",
  cache_cfg := ⟨λ ns, ns.mfoldl (λ dict n, do
    val ← to_additive_attr.get_param n,
    pure $ dict.insert n val) mk_name_map, []⟩,
  parser    := lean.parser.ident,
  after_set := some $ λ src _ _, do
    env ← get_env,
    dict ← to_additive_attr.get_cache,
    tgt ← to_additive_attr.get_param src,
    (get_decl tgt >> skip) <|>
      transport_with_dict dict src tgt }

end transport

/- map operations -/
attribute [to_additive has_add.add] has_mul.mul
attribute [to_additive has_zero.zero] has_one.one
attribute [to_additive has_neg.neg] has_inv.inv
attribute [to_additive has_add] has_mul
attribute [to_additive has_zero] has_one
attribute [to_additive has_neg] has_inv

/- map constructors -/
attribute [to_additive has_add.mk] has_mul.mk
attribute [to_additive has_zero.mk] has_one.mk
attribute [to_additive has_neg.mk] has_inv.mk

/- map structures -/
attribute [to_additive add_semigroup] semigroup
attribute [to_additive add_semigroup.mk] semigroup.mk
attribute [to_additive add_semigroup.to_has_add] semigroup.to_has_mul
attribute [to_additive add_semigroup.add_assoc] semigroup.mul_assoc

attribute [to_additive add_comm_semigroup] comm_semigroup
attribute [to_additive add_comm_semigroup.mk] comm_semigroup.mk
attribute [to_additive add_comm_semigroup.to_add_semigroup] comm_semigroup.to_semigroup
attribute [to_additive add_comm_semigroup.add_comm] comm_semigroup.mul_comm

attribute [to_additive add_left_cancel_semigroup] left_cancel_semigroup
attribute [to_additive add_left_cancel_semigroup.mk] left_cancel_semigroup.mk
attribute [to_additive add_left_cancel_semigroup.to_add_semigroup] left_cancel_semigroup.to_semigroup
attribute [to_additive add_left_cancel_semigroup.add_left_cancel] left_cancel_semigroup.mul_left_cancel

attribute [to_additive add_right_cancel_semigroup] right_cancel_semigroup
attribute [to_additive add_right_cancel_semigroup.mk] right_cancel_semigroup.mk
attribute [to_additive add_right_cancel_semigroup.to_add_semigroup] right_cancel_semigroup.to_semigroup
attribute [to_additive add_right_cancel_semigroup.add_right_cancel] right_cancel_semigroup.mul_right_cancel

attribute [to_additive add_monoid] monoid
attribute [to_additive add_monoid.mk] monoid.mk
attribute [to_additive add_monoid.to_has_zero] monoid.to_has_one
attribute [to_additive add_monoid.to_add_semigroup] monoid.to_semigroup
attribute [to_additive add_monoid.add] monoid.mul
attribute [to_additive add_monoid.add_assoc] monoid.mul_assoc
attribute [to_additive add_monoid.zero] monoid.one
attribute [to_additive add_monoid.zero_add] monoid.one_mul
attribute [to_additive add_monoid.add_zero] monoid.mul_one

attribute [to_additive add_comm_monoid] comm_monoid
attribute [to_additive add_comm_monoid.mk] comm_monoid.mk
attribute [to_additive add_comm_monoid.to_add_monoid] comm_monoid.to_monoid
attribute [to_additive add_comm_monoid.to_add_comm_semigroup] comm_monoid.to_comm_semigroup

attribute [to_additive add_group] group
attribute [to_additive add_group.mk] group.mk
attribute [to_additive add_group.to_has_neg] group.to_has_inv
attribute [to_additive add_group.to_add_monoid] group.to_monoid
attribute [to_additive add_group.add_left_neg] group.mul_left_inv
attribute [to_additive add_group.add] group.mul
attribute [to_additive add_group.add_assoc] group.mul_assoc

attribute [to_additive add_comm_group] comm_group
attribute [to_additive add_comm_group.mk] comm_group.mk
attribute [to_additive add_comm_group.to_add_group] comm_group.to_group
attribute [to_additive add_comm_group.to_add_comm_monoid] comm_group.to_comm_monoid

/- map theorems -/
attribute [to_additive add_assoc] mul_assoc
attribute [to_additive add_semigroup_to_is_associative] semigroup_to_is_associative
attribute [to_additive add_comm] mul_comm
attribute [to_additive add_comm_semigroup_to_is_commutative] comm_semigroup_to_is_commutative
attribute [to_additive add_left_comm] mul_left_comm
attribute [to_additive add_right_comm] mul_right_comm
attribute [to_additive add_left_cancel] mul_left_cancel
attribute [to_additive add_right_cancel] mul_right_cancel
attribute [to_additive add_left_cancel_iff] mul_left_cancel_iff
attribute [to_additive add_right_cancel_iff] mul_right_cancel_iff
attribute [to_additive zero_add] one_mul
attribute [to_additive add_zero] mul_one
attribute [to_additive add_left_neg] mul_left_inv
attribute [to_additive neg_add_self] inv_mul_self
attribute [to_additive neg_add_cancel_left] inv_mul_cancel_left
attribute [to_additive neg_add_cancel_right] inv_mul_cancel_right
attribute [to_additive neg_eq_of_add_eq_zero] inv_eq_of_mul_eq_one
attribute [to_additive neg_zero] one_inv
attribute [to_additive neg_neg] inv_inv
attribute [to_additive add_right_neg] mul_right_inv
attribute [to_additive add_neg_self] mul_inv_self
attribute [to_additive neg_inj] inv_inj
attribute [to_additive add_group.add_left_cancel] group.mul_left_cancel
attribute [to_additive add_group.add_right_cancel] group.mul_right_cancel
attribute [to_additive add_group.to_left_cancel_add_semigroup] group.to_left_cancel_semigroup
attribute [to_additive add_group.to_right_cancel_add_semigroup] group.to_right_cancel_semigroup
attribute [to_additive add_neg_cancel_left] mul_inv_cancel_left
attribute [to_additive add_neg_cancel_right] mul_inv_cancel_right
attribute [to_additive neg_add_rev] mul_inv_rev
attribute [to_additive eq_neg_of_eq_neg] eq_inv_of_eq_inv
attribute [to_additive eq_neg_of_add_eq_zero] eq_inv_of_mul_eq_one
attribute [to_additive eq_add_neg_of_add_eq] eq_mul_inv_of_mul_eq
attribute [to_additive eq_neg_add_of_add_eq] eq_inv_mul_of_mul_eq
attribute [to_additive neg_add_eq_of_eq_add] inv_mul_eq_of_eq_mul
attribute [to_additive add_neg_eq_of_eq_add] mul_inv_eq_of_eq_mul
attribute [to_additive eq_add_of_add_neg_eq] eq_mul_of_mul_inv_eq
attribute [to_additive eq_add_of_neg_add_eq] eq_mul_of_inv_mul_eq
attribute [to_additive add_eq_of_eq_neg_add] mul_eq_of_eq_inv_mul
attribute [to_additive add_eq_of_eq_add_neg] mul_eq_of_eq_mul_inv
attribute [to_additive neg_add] mul_inv

end pending_1857

universes u v
variables {α : Type u} {β : Type v}

def additive (α : Type*) := α
def multiplicative (α : Type*) := α

instance [semigroup α] : add_semigroup (additive α) :=
{ add := ((*) : α → α → α),
  add_assoc := @mul_assoc _ _ }

instance [add_semigroup α] : semigroup (multiplicative α) :=
{ mul := ((+) : α → α → α),
  mul_assoc := @add_assoc _ _ }

instance [comm_semigroup α] : add_comm_semigroup (additive α) :=
{ add_comm := @mul_comm _ _,
  ..additive.add_semigroup }

instance [add_comm_semigroup α] : comm_semigroup (multiplicative α) :=
{ mul_comm := @add_comm _ _,
  ..multiplicative.semigroup }

instance [left_cancel_semigroup α] : add_left_cancel_semigroup (additive α) :=
{ add_left_cancel := @mul_left_cancel _ _,
  ..additive.add_semigroup }

instance [add_left_cancel_semigroup α] : left_cancel_semigroup (multiplicative α) :=
{ mul_left_cancel := @add_left_cancel _ _,
  ..multiplicative.semigroup }

instance [right_cancel_semigroup α] : add_right_cancel_semigroup (additive α) :=
{ add_right_cancel := @mul_right_cancel _ _,
  ..additive.add_semigroup }

instance [add_right_cancel_semigroup α] : right_cancel_semigroup (multiplicative α) :=
{ mul_right_cancel := @add_right_cancel _ _,
  ..multiplicative.semigroup }

@[simp, to_additive add_left_inj]
theorem mul_left_inj [left_cancel_semigroup α] (a : α) {b c : α} : a * b = a * c ↔ b = c :=
⟨mul_left_cancel, congr_arg _⟩

@[simp, to_additive add_right_inj]
theorem mul_right_inj [right_cancel_semigroup α] (a : α) {b c : α} : b * a = c * a ↔ b = c :=
⟨mul_right_cancel, congr_arg _⟩

structure units (α : Type u) [monoid α] :=
(val : α)
(inv : α)
(val_inv : val * inv = 1)
(inv_val : inv * val = 1)

namespace units
variables [monoid α] {a b c : units α}

instance : has_coe (units α) α := ⟨val⟩

@[extensionality] theorem ext : ∀ {a b : units α}, (a : α) = b → a = b
| ⟨v, i₁, vi₁, iv₁⟩ ⟨v', i₂, vi₂, iv₂⟩ e :=
  by change v = v' at e; subst v'; congr;
      simpa [iv₂, vi₁] using mul_assoc i₂ v i₁

theorem ext_iff {a b : units α} : a = b ↔ (a : α) = b :=
⟨congr_arg _, ext⟩

instance [decidable_eq α] : decidable_eq (units α)
| a b := decidable_of_iff' _ ext_iff

protected def mul (u₁ u₂ : units α) : units α :=
⟨u₁.val * u₂.val, u₂.inv * u₁.inv,
  have u₁.val * (u₂.val * u₂.inv) * u₁.inv = 1,
    by rw [u₂.val_inv]; simp [u₁.val_inv],
  by simpa [mul_comm, mul_assoc],
  have u₂.inv * (u₁.inv * u₁.val) * u₂.val = 1,
    by rw [u₁.inv_val]; simp [u₂.inv_val],
  by simpa [mul_comm, mul_assoc]⟩

protected def inv' (u : units α) : units α :=
⟨u.inv, u.val, u.inv_val, u.val_inv⟩

instance : has_mul (units α) := ⟨units.mul⟩
instance : has_one (units α) := ⟨⟨1, 1, mul_one 1, one_mul 1⟩⟩
instance : has_inv (units α) := ⟨units.inv'⟩

variables (a b)
@[simp] lemma mul_coe : (↑(a * b) : α) = a * b := rfl
@[simp] lemma one_coe : ((1 : units α) : α) = 1 := rfl
lemma val_coe : (↑a : α) = a.val := rfl
lemma inv_coe : ((a⁻¹ : units α) : α) = a.inv := rfl
@[simp] lemma inv_mul : (↑a⁻¹ * a : α) = 1 := inv_val _
@[simp] lemma mul_inv : (a * ↑a⁻¹ : α) = 1 := val_inv _

@[simp] lemma mul_inv_cancel_left (a : units α) (b : α) : (a:α) * (↑a⁻¹ * b) = b :=
by rw [← mul_assoc, mul_inv, one_mul]

@[simp] lemma inv_mul_cancel_left (a : units α) (b : α) : (↑a⁻¹:α) * (a * b) = b :=
by rw [← mul_assoc, inv_mul, one_mul]

@[simp] lemma mul_inv_cancel_right (a : α) (b : units α) : a * b * ↑b⁻¹ = a :=
by rw [mul_assoc, mul_inv, mul_one]

@[simp] lemma inv_mul_cancel_right (a : α) (b : units α) : a * ↑b⁻¹ * b = a :=
by rw [mul_assoc, inv_mul, mul_one]

instance : group (units α) :=
by refine {mul := (*), one := 1, inv := has_inv.inv, ..};
  { intros, apply ext, simp [mul_assoc] }

instance {α} [comm_monoid α] : comm_group (units α) :=
{ mul_comm := λ u₁ u₂, ext $ mul_comm _ _, ..units.group }

instance [has_repr α] : has_repr (units α) := ⟨repr ∘ val⟩

@[simp] theorem mul_left_inj (a : units α) {b c : α} : (a:α) * b = a * c ↔ b = c :=
⟨λ h, by simpa using congr_arg ((*) ↑(a⁻¹ : units α)) h, congr_arg _⟩

@[simp] theorem mul_right_inj (a : units α) {b c : α} : b * a = c * a ↔ b = c :=
⟨λ h, by simpa using congr_arg (* ↑(a⁻¹ : units α)) h, congr_arg _⟩

end units

theorem nat.units_eq_one (u : units ℕ) : u = 1 :=
units.ext begin
  cases nat.eq_zero_or_pos u with h h,
  { simpa [h] using u.inv_mul },
  cases nat.eq_zero_or_pos ↑u⁻¹ with h' h',
  { simpa [h'] using u.inv_mul },
  refine le_antisymm _ h,
  simpa using nat.mul_le_mul_left u h'
end

def units.mk_of_mul_eq_one [comm_monoid α] (a b : α) (hab : a * b = 1) : units α :=
⟨a, b, hab, by rwa mul_comm a b at hab⟩

@[to_additive with_zero]
def with_one (α) := option α

@[to_additive with_zero.has_coe_t]
instance : has_coe_t α (with_one α) := ⟨some⟩

instance [semigroup α] : monoid (with_one α) :=
{ one       := none,
  mul       := option.lift_or_get (*),
  mul_assoc := (option.lift_or_get_assoc _).1,
  one_mul   := (option.lift_or_get_is_left_id _).1,
  mul_one   := (option.lift_or_get_is_right_id _).1 }

attribute [to_additive with_zero.add_monoid._proof_1] with_one.monoid._proof_1
attribute [to_additive with_zero.add_monoid._proof_2] with_one.monoid._proof_2
attribute [to_additive with_zero.add_monoid._proof_3] with_one.monoid._proof_3
attribute [to_additive with_zero.add_monoid] with_one.monoid

instance [semigroup α] : mul_zero_class (with_zero α) :=
{ zero      := none,
  mul       := λ o₁ o₂, o₁.bind (λ a, o₂.map (λ b, a * b)),
  zero_mul  := by simp,
  mul_zero  := λ a, by cases a; simp,
  ..with_zero.add_monoid }

instance [semigroup α] : semigroup (with_zero α) :=
{ mul_assoc := λ a b c, begin
    cases a with a, {refl},
    cases b with b, {refl},
    cases c with c, {refl},
    simp [mul_assoc]
  end,
  ..with_zero.mul_zero_class }

instance [comm_semigroup α] : comm_semigroup (with_zero α) :=
{ mul_comm := λ a b, begin
    cases a with a; cases b with b; try {refl},
    exact congr_arg some (mul_comm _ _)
  end,
  ..with_zero.semigroup }

instance [monoid α] : monoid (with_zero α) :=
{ one := some 1,
  one_mul := λ a, by cases a;
    [refl, exact congr_arg some (one_mul a)],
  mul_one := λ a, by cases a;
    [refl, exact congr_arg some (mul_one a)],
  ..with_zero.semigroup }

instance [comm_monoid α] : comm_monoid (with_zero α) :=
{ ..with_zero.monoid, ..with_zero.comm_semigroup }

instance [monoid α] : add_monoid (additive α) :=
{ zero     := (1 : α),
  zero_add := @one_mul _ _,
  add_zero := @mul_one _ _,
  ..additive.add_semigroup }

instance [add_monoid α] : monoid (multiplicative α) :=
{ one     := (0 : α),
  one_mul := @zero_add _ _,
  mul_one := @add_zero _ _,
  ..multiplicative.semigroup }

section monoid
  variables [monoid α] {a b c : α}

  /-- Partial division. It is defined when the
    second argument is invertible, and unlike the division operator
    in `division_ring` it is not totalized at zero. -/
  def divp (a : α) (u) : α := a * (u⁻¹ : units α)

  infix ` /ₚ `:70 := divp

  @[simp] theorem divp_self (u : units α) : (u : α) /ₚ u = 1 := by simp [divp]

  @[simp] theorem divp_one (a : α) : a /ₚ 1 = a := by simp [divp]

  theorem divp_assoc (a b : α) (u : units α) : a * b /ₚ u = a * (b /ₚ u) :=
  by simp [divp, mul_assoc]

  @[simp] theorem divp_mul_cancel (a : α) (u : units α) : a /ₚ u * u = a :=
  by simp [divp, mul_assoc]

  @[simp] theorem mul_divp_cancel (a : α) (u : units α) : (a * u) /ₚ u = a :=
  by simp [divp, mul_assoc]

  @[simp] theorem divp_right_inj (u : units α) {a b : α} : a /ₚ u = b /ₚ u ↔ a = b :=
  units.mul_right_inj _

  theorem divp_eq_one (a : α) (u : units α) : a /ₚ u = 1 ↔ a = u :=
  (units.mul_right_inj u).symm.trans $ by simp

  @[simp] theorem one_divp (u : units α) : 1 /ₚ u = ↑u⁻¹ :=
  by simp [divp]

end monoid

instance [comm_semigroup α] : comm_monoid (with_one α) :=
{ mul_comm := (option.lift_or_get_comm _).1,
  ..with_one.monoid }

instance [add_comm_semigroup α] : add_comm_monoid (with_zero α) :=
{ add_comm := (option.lift_or_get_comm _).1,
  ..with_zero.add_monoid }
attribute [to_additive with_zero.add_comm_monoid] with_one.comm_monoid

instance [comm_monoid α] : add_comm_monoid (additive α) :=
{ add_comm := @mul_comm α _,
  ..additive.add_monoid }

instance [add_comm_monoid α] : comm_monoid (multiplicative α) :=
{ mul_comm := @add_comm α _,
  ..multiplicative.monoid }

instance [group α] : add_group (additive α) :=
{ neg := @has_inv.inv α _,
  add_left_neg := @mul_left_inv _ _,
  ..additive.add_monoid }

instance [add_group α] : group (multiplicative α) :=
{ inv := @has_neg.neg α _,
  mul_left_inv := @add_left_neg _ _,
  ..multiplicative.monoid }

section group
  variables [group α] {a b c : α}

  instance : has_lift α (units α) :=
  ⟨λ a, ⟨a, a⁻¹, mul_inv_self _, inv_mul_self _⟩⟩

  @[simp, to_additive neg_inj']
  theorem inv_inj' : a⁻¹ = b⁻¹ ↔ a = b :=
  ⟨λ h, by rw ← inv_inv a; simp [h], congr_arg _⟩

  @[to_additive eq_of_neg_eq_neg]
  theorem eq_of_inv_eq_inv : a⁻¹ = b⁻¹ → a = b :=
  inv_inj'.1

  @[simp, to_additive add_self_iff_eq_zero]
  theorem mul_self_iff_eq_one : a * a = a ↔ a = 1 :=
  by have := @mul_left_inj _ _ a a 1; rwa mul_one at this

  @[simp, to_additive neg_eq_zero]
  theorem inv_eq_one : a⁻¹ = 1 ↔ a = 1 :=
  by rw [← @inv_inj' _ _ a 1, one_inv]

  @[simp, to_additive neg_ne_zero]
  theorem inv_ne_one : a⁻¹ ≠ 1 ↔ a ≠ 1 :=
  not_congr inv_eq_one

  @[to_additive left_inverse_neg]
  theorem left_inverse_inv (α) [group α] :
    function.left_inverse (λ a : α, a⁻¹) (λ a, a⁻¹) :=
  assume a, inv_inv a

  attribute [simp] mul_inv_cancel_left add_neg_cancel_left
                   mul_inv_cancel_right add_neg_cancel_right

  @[to_additive eq_neg_iff_eq_neg]
  theorem eq_inv_iff_eq_inv : a = b⁻¹ ↔ b = a⁻¹ :=
  ⟨eq_inv_of_eq_inv, eq_inv_of_eq_inv⟩

  @[to_additive neg_eq_iff_neg_eq]
  theorem inv_eq_iff_inv_eq : a⁻¹ = b ↔ b⁻¹ = a :=
  by rw [eq_comm, @eq_comm _ _ a, eq_inv_iff_eq_inv]

  @[to_additive add_eq_zero_iff_eq_neg]
  theorem mul_eq_one_iff_eq_inv : a * b = 1 ↔ a = b⁻¹ :=
  by simpa [mul_left_inv, -mul_right_inj] using @mul_right_inj _ _ b a (b⁻¹)

  @[to_additive add_eq_zero_iff_neg_eq]
  theorem mul_eq_one_iff_inv_eq : a * b = 1 ↔ a⁻¹ = b :=
  by rw [mul_eq_one_iff_eq_inv, eq_inv_iff_eq_inv, eq_comm]

  @[to_additive eq_neg_iff_add_eq_zero]
  theorem eq_inv_iff_mul_eq_one : a = b⁻¹ ↔ a * b = 1 :=
  mul_eq_one_iff_eq_inv.symm

  @[to_additive neg_eq_iff_add_eq_zero]
  theorem inv_eq_iff_mul_eq_one : a⁻¹ = b ↔ a * b = 1 :=
  mul_eq_one_iff_inv_eq.symm

  @[to_additive eq_add_neg_iff_add_eq]
  theorem eq_mul_inv_iff_mul_eq : a = b * c⁻¹ ↔ a * c = b :=
  ⟨λ h, by simp [h], λ h, by simp [h.symm]⟩

  @[to_additive eq_neg_add_iff_add_eq]
  theorem eq_inv_mul_iff_mul_eq : a = b⁻¹ * c ↔ b * a = c :=
  ⟨λ h, by simp [h], λ h, by simp [h.symm]⟩

  @[to_additive neg_add_eq_iff_eq_add]
  theorem inv_mul_eq_iff_eq_mul : a⁻¹ * b = c ↔ b = a * c :=
  ⟨λ h, by simp [h.symm], λ h, by simp [h]⟩

  @[to_additive add_neg_eq_iff_eq_add]
  theorem mul_inv_eq_iff_eq_mul : a * b⁻¹ = c ↔ a = c * b :=
  ⟨λ h, by simp [h.symm], λ h, by simp [h]⟩

  @[to_additive add_neg_eq_zero]
  theorem mul_inv_eq_one {a b : α} : a * b⁻¹ = 1 ↔ a = b :=
  by rw [mul_eq_one_iff_eq_inv, inv_inv]

  @[to_additive neg_comm_of_comm]
  theorem inv_comm_of_comm {a b : α} (H : a * b = b * a) : a⁻¹ * b = b * a⁻¹ :=
  begin
    have : a⁻¹ * (b * a) * a⁻¹ = a⁻¹ * (a * b) * a⁻¹ :=
      congr_arg (λ x:α, a⁻¹ * x * a⁻¹) H.symm,
    rwa [mul_assoc, mul_assoc, mul_inv_self, mul_one,
        ← mul_assoc, inv_mul_self, one_mul] at this; exact h
  end

end group

instance [comm_group α] : add_comm_group (additive α) :=
{ add_comm := @mul_comm α _,
  ..additive.add_group }

instance [add_comm_group α] : comm_group (multiplicative α) :=
{ mul_comm := @add_comm α _,
  ..multiplicative.group }

section add_monoid
  variables [add_monoid α] {a b c : α}

  @[simp] lemma bit0_zero : bit0 0 = 0 := add_zero _
  @[simp] lemma bit1_zero : bit1 0 = 1 := add_zero _
end add_monoid

section add_group
  variables [add_group α] {a b c : α}

  local attribute [simp] sub_eq_add_neg

  def sub_sub_cancel := @sub_sub_self

  @[simp] lemma sub_left_inj : a - b = a - c ↔ b = c :=
  (add_left_inj _).trans neg_inj'

  @[simp] lemma sub_right_inj : b - a = c - a ↔ b = c :=
  add_right_inj _

  lemma sub_add_sub_cancel (a b c : α) : (a - b) + (b - c) = a - c :=
  by simp

  lemma sub_sub_sub_cancel_right (a b c : α) : (a - c) - (b - c) = a - b :=
  by simp

  theorem sub_eq_zero : a - b = 0 ↔ a = b :=
  ⟨eq_of_sub_eq_zero, λ h, by simp [h]⟩

  theorem sub_ne_zero : a - b ≠ 0 ↔ a ≠ b :=
  not_congr sub_eq_zero

  theorem eq_sub_iff_add_eq : a = b - c ↔ a + c = b :=
  by split; intro h; simp [h, eq_add_neg_iff_add_eq]

  theorem sub_eq_iff_eq_add : a - b = c ↔ a = c + b :=
  by split; intro h; simp [*, add_neg_eq_iff_eq_add] at *

  theorem eq_iff_eq_of_sub_eq_sub {a b c d : α} (H : a - b = c - d) : a = b ↔ c = d :=
  by rw [← sub_eq_zero, H, sub_eq_zero]

  theorem left_inverse_sub_add_left (c : α) : function.left_inverse (λ x, x - c) (λ x, x + c) :=
  assume x, add_sub_cancel x c

  theorem left_inverse_add_left_sub (c : α) : function.left_inverse (λ x, x + c) (λ x, x - c) :=
  assume x, sub_add_cancel x c

  theorem left_inverse_add_right_neg_add (c : α) :
      function.left_inverse (λ x, c + x) (λ x, - c + x) :=
  assume x, add_neg_cancel_left c x

  theorem left_inverse_neg_add_add_right (c : α) :
      function.left_inverse (λ x, - c + x) (λ x, c + x) :=
  assume x, neg_add_cancel_left c x
end add_group

section add_comm_group
  variables [add_comm_group α] {a b c : α}

  lemma sub_eq_neg_add (a b : α) : a - b = -b + a :=
  by simp

  theorem neg_add' (a b : α) : -(a + b) = -a - b := neg_add a b

  lemma eq_sub_iff_add_eq' : a = b - c ↔ c + a = b :=
  by rw [eq_sub_iff_add_eq, add_comm]

  lemma sub_eq_iff_eq_add' : a - b = c ↔ a = b + c :=
  by rw [sub_eq_iff_eq_add, add_comm]

  lemma add_sub_cancel' (a b : α) : a + b - a = b :=
  by simp

  lemma add_sub_cancel'_right (a b : α) : a + (b - a) = b :=
  by rw [← add_sub_assoc, add_sub_cancel']

  lemma sub_right_comm (a b c : α) : a - b - c = a - c - b :=
  by simp

  lemma sub_add_sub_cancel' (a b c : α) : (a - b) + (c - a) = c - b :=
  by rw add_comm; apply sub_add_sub_cancel

  lemma sub_sub_sub_cancel_left (a b c : α) : (c - a) - (c - b) = b - a :=
  by simp

end add_comm_group

section is_conj
variables [group α] [group β]

def is_conj (a b : α) := ∃ c : α, c * a * c⁻¹ = b

@[refl] lemma is_conj_refl (a : α) : is_conj a a := ⟨1, by simp⟩

@[symm] lemma is_conj_symm (a b : α) : is_conj a b → is_conj b a
| ⟨c, hc⟩ := ⟨c⁻¹, by simp [hc.symm, mul_assoc]⟩

@[trans] lemma is_conj_trans (a b c : α) : is_conj a b → is_conj b c → is_conj a c
| ⟨c₁, hc₁⟩ ⟨c₂, hc₂⟩ := ⟨c₂ * c₁, by simp [hc₁.symm, hc₂.symm, mul_assoc]⟩

@[simp] lemma is_conj_iff_eq {α : Type*} [comm_group α] {a b : α} : is_conj a b ↔ a = b :=
⟨λ ⟨c, hc⟩, by rw [← hc, mul_right_comm, mul_inv_self, one_mul], λ h, by rw h⟩

end is_conj

/-- Predicate for group homomorphism. -/
class is_group_hom [group α] [group β] (f : α → β) : Prop :=
(mul : ∀ a b : α, f (a * b) = f a * f b)

class is_add_group_hom [add_group α] [add_group β] (f : α → β) : Prop :=
(add : ∀ a b, f (a + b) = f a + f b)

attribute [to_additive is_add_group_hom] is_group_hom
attribute [to_additive is_add_group_hom.add] is_group_hom.mul
attribute [to_additive is_add_group_hom.mk] is_group_hom.mk

namespace is_group_hom
variables [group α] [group β] (f : α → β) [is_group_hom f]

@[to_additive is_add_group_hom.zero]
theorem one : f 1 = 1 :=
mul_self_iff_eq_one.1 $ by simp [(mul f 1 1).symm]

@[to_additive is_add_group_hom.neg]
theorem inv (a : α) : f a⁻¹ = (f a)⁻¹ :=
eq.symm $ inv_eq_of_mul_eq_one $ by simp [(mul f a a⁻¹).symm, one f]

@[to_additive is_add_group_hom.id]
instance id : is_group_hom (@id α) :=
⟨λ _ _, rfl⟩

@[to_additive is_add_group_hom.comp]
instance comp {γ} [group γ] (g : β → γ) [is_group_hom g] :
  is_group_hom (g ∘ f) :=
⟨λ x y, calc
  g (f (x * y)) = g (f x * f y)       : by rw mul f
  ...           = g (f x) * g (f y)   : by rw mul g⟩

protected lemma is_conj (f : α → β) [is_group_hom f] {a b : α} : is_conj a b → is_conj (f a) (f b)
| ⟨c, hc⟩ := ⟨f c, by rw [← is_group_hom.mul f, ← is_group_hom.inv f, ← is_group_hom.mul f, hc]⟩

end is_group_hom

attribute [instance] is_add_group_hom.id

/-- Predicate for group anti-homomorphism, or a homomorphism
  into the opposite group. -/
class is_group_anti_hom {β : Type*} [group α] [group β] (f : α → β) : Prop :=
(mul : ∀ a b : α, f (a * b) = f b * f a)

namespace is_group_anti_hom
variables [group α] [group β] (f : α → β) [w : is_group_anti_hom f]
include w

theorem one : f 1 = 1 :=
mul_self_iff_eq_one.1 $ by simp [(mul f 1 1).symm]

theorem inv (a : α) : f a⁻¹ = (f a)⁻¹ :=
eq.symm $ inv_eq_of_mul_eq_one $ by simp [(mul f a⁻¹ a).symm, one f]

end is_group_anti_hom

theorem inv_is_group_anti_hom [group α] : is_group_anti_hom (λ x : α, x⁻¹) :=
⟨mul_inv_rev⟩

namespace is_add_group_hom
variables [add_group α] [add_group β] (f : α → β) [is_add_group_hom f]

lemma sub (a b) : f (a - b) = f a - f b :=
calc f (a - b) = f (a + -b)   : rfl
           ... = f a + f (-b) : add f _ _
           ... = f a - f b    : by  simp[neg f]

end is_add_group_hom
