{-# OPTIONS --without-K #-}

-- Finished 6pm Th, March 24! yay!
-- Bit thanks to tzaikin for posting his work online (some of his macros
-- were essential for this proof for me) and to the code we saw in class today.


module EH where

open import Level using (_⊔_)
open import Data.Product using (Σ; _,_)
open import Function renaming (_∘_ to _○_)

infixr 8  _∘_     -- path composition
infixr 8  _⋆_     -- horizontal path composition
infix  4  _≡_     -- propositional equality
infix  4  _∼_     -- homotopy between two functions 
infix  4  _≃_     -- type of equivalences
-- macros from tzaikin for equational rewriting over non-standard ≡
infixr 4 _≡⟨_⟩_ 
infix 4  _∎ 

------------------------------------------------------------------------------
-- A few HoTT primitives

data _≡_ {ℓ} {A : Set ℓ} : (a b : A) → Set ℓ where
  refl : (a : A) → (a ≡ a)

pathInd : ∀ {u ℓ} → {A : Set u} → 
          (C : {x y : A} → x ≡ y → Set ℓ) → 
          (c : (x : A) → C (refl x)) → 
          ({x y : A} (p : x ≡ y) → C p)
pathInd C c (refl x) = c x

--

! : ∀ {u} → {A : Set u} {x y : A} → (x ≡ y) → (y ≡ x)
! = pathInd (λ {x} {y} _ → y ≡ x) refl

_∘_ : ∀ {u} → {A : Set u} → {x y z : A} → (x ≡ y) → (y ≡ z) → (x ≡ z)
_∘_ {u} {A} {x} {y} {z} p q = 
  pathInd {u}
    (λ {x} {y} p → ((z : A) → (q : y ≡ z) → (x ≡ z)))
    (λ x z q → pathInd (λ {x} {z} _ → x ≡ z) refl {x} {z} q)
    {x} {y} p z q

-- Handy "macros" (from tzaikin)
_∎ : {A : Set} → (p : A) → p ≡ p
p ∎ = refl p

_≡⟨_⟩_ : {A : Set} → {q r : A} → (p : A) → p ≡ q → q ≡ r → p ≡ r
p ≡⟨ α ⟩ β = α ∘ β


--

RU : {A : Set} {x y : A} → (p : x ≡ y) → (p ≡ p ∘ refl y) 
RU {A} {x} {y} p = 
  pathInd
    (λ {x} {y} p → p ≡ p ∘ (refl y)) 
    (λ x → refl (refl x))
    {x} {y} p 

LU : {A : Set} {x y : A} → (p : x ≡ y) → (p ≡ refl x ∘ p) 
LU {A} {x} {y} p = 
  pathInd
    (λ {x} {y} p → p ≡ (refl x) ∘ p)
    (λ x → refl (refl x))
    {x} {y} p 

invTransL : {A : Set} {x y : A} → (p : x ≡ y) → (! p ∘ p ≡ refl y)
invTransL {A} {x} {y} p = 
  pathInd 
    (λ {x} {y} p → ! p ∘ p ≡ refl y)
    (λ x → refl (refl x))
    {x} {y} p

invTransR : ∀ {ℓ} {A : Set ℓ} {x y : A} → (p : x ≡ y) → (p ∘ ! p ≡ refl x)
invTransR {ℓ} {A} {x} {y} p = 
  pathInd
    (λ {x} {y} p → p ∘ ! p ≡ refl x)
    (λ x → refl (refl x))
    {x} {y} p

invId : {A : Set} {x y : A} → (p : x ≡ y) → (! (! p) ≡ p)
invId {A} {x} {y} p =
  pathInd 
    (λ {x} {y} p → ! (! p) ≡ p)
    (λ x → refl (refl x))
    {x} {y} p

assocP : {A : Set} {x y z w : A} → (p : x ≡ y) → (q : y ≡ z) → (r : z ≡ w) →
         (p ∘ (q ∘ r) ≡ (p ∘ q) ∘ r)
assocP {A} {x} {y} {z} {w} p q r =
  pathInd
    (λ {x} {y} p → (z : A) → (w : A) → (q : y ≡ z) → (r : z ≡ w) → 
      p ∘ (q ∘ r) ≡ (p ∘ q) ∘ r)
    (λ x z w q r → 
      pathInd
        (λ {x} {z} q → (w : A) → (r : z ≡ w) → 
          (refl x) ∘ (q ∘ r) ≡ ((refl x) ∘ q) ∘ r)
        (λ x w r → 
          pathInd
            (λ {x} {w} r → 
              (refl x) ∘ ((refl x) ∘ r) ≡ 
              ((refl x) ∘ (refl x)) ∘ r)
            (λ x → (refl (refl x)))
            {x} {w} r)
        {x} {z} q w r)
    {x} {y} p z w q r

invComp : {A : Set} {x y z : A} → (p : x ≡ y) → (q : y ≡ z) → 
          ! (p ∘ q) ≡ ! q ∘ ! p
invComp {A} {x} {y} {z} p q = 
  pathInd
    (λ {x} {y} p → (z : A) → (q : y ≡ z) → ! (p ∘ q) ≡ ! q ∘ ! p)
    (λ x z q → 
      pathInd 
        (λ {x} {z} q → ! (refl x ∘ q) ≡ ! q ∘ ! (refl x))
        (λ x → refl (refl x)) 
        {x} {z} q)
    {x} {y} p z q

--

ap : ∀ {ℓ ℓ'} → {A : Set ℓ} {B : Set ℓ'} {x y : A} → 
     (f : A → B) → (x ≡ y) → (f x ≡ f y)
ap {ℓ} {ℓ'} {A} {B} {x} {y} f p = 
  pathInd -- on p
    (λ {x} {y} p → f x ≡ f y) 
    (λ x → refl (f x))
    {x} {y} p

apfTrans : ∀ {u} → {A B : Set u} {x y z : A} → 
  (f : A → B) → (p : x ≡ y) → (q : y ≡ z) → ap f (p ∘ q) ≡ (ap f p) ∘ (ap f q)
apfTrans {u} {A} {B} {x} {y} {z} f p q = 
  pathInd {u}
    (λ {x} {y} p → (z : A) → (q : y ≡ z) → 
      ap f (p ∘ q) ≡ (ap f p) ∘ (ap f q))
    (λ x z q → 
      pathInd {u}
        (λ {x} {z} q → 
          ap f (refl x ∘ q) ≡ (ap f (refl x)) ∘ (ap f q))
        (λ x → refl (refl (f x)))
        {x} {z} q)
    {x} {y} p z q

apfInv : ∀ {u} → {A B : Set u} {x y : A} → (f : A → B) → (p : x ≡ y) → 
         ap f (! p) ≡ ! (ap f p) 
apfInv {u} {A} {B} {x} {y} f p =
  pathInd {u}
    (λ {x} {y} p → ap f (! p) ≡ ! (ap f p))
    (λ x → refl (ap f (refl x)))
    {x} {y} p

apfComp : {A B C : Set} {x y : A} → (f : A → B) → (g : B → C) → (p : x ≡ y) → 
          ap g (ap f p) ≡ ap (g ○ f) p 
apfComp {A} {B} {C} {x} {y} f g p =
  pathInd 
    (λ {x} {y} p → ap g (ap f p) ≡ ap (g ○ f) p)
    (λ x → refl (ap g (ap f (refl x))))
    {x} {y} p

apfId : {A : Set} {x y : A} → (p : x ≡ y) → ap id p ≡ p
apfId {A} {x} {y} p = 
  pathInd 
    (λ {x} {y} p → ap id p ≡ p)
    (λ x → refl (refl x))
    {x} {y} p

--

transport : ∀ {ℓ ℓ'} → {A : Set ℓ} {x y : A} → 
  (P : A → Set ℓ') → (p : x ≡ y) → P x → P y
transport {ℓ} {ℓ'} {A} {x} {y} P p = 
  pathInd -- on p
    (λ {x} {y} p → (P x → P y))
    (λ _ → id)
    {x} {y} p

apd : ∀ {ℓ ℓ'} → {A : Set ℓ} {B : A → Set ℓ'} {x y : A} → (f : (a : A) → B a) → 
  (p : x ≡ y) → (transport B p (f x) ≡ f y)
apd {ℓ} {ℓ'} {A} {B} {x} {y} f p = 
  pathInd 
    (λ {x} {y} p → transport B p (f x) ≡ f y)
    (λ x → refl (f x))
    {x} {y} p

-- Homotopies and equivalences

_∼_ : ∀ {ℓ ℓ'} → {A : Set ℓ} {P : A → Set ℓ'} → 
      (f g : (x : A) → P x) → Set (ℓ ⊔ ℓ')
_∼_ {ℓ} {ℓ'} {A} {P} f g = (x : A) → f x ≡ g x

record qinv {ℓ ℓ'} {A : Set ℓ} {B : Set ℓ'} (f : A → B) : 
  Set (ℓ ⊔ ℓ') where
  constructor mkqinv
  field
    g : B → A 
    α : (f ○ g) ∼ id
    β : (g ○ f) ∼ id

record isequiv {ℓ ℓ'} {A : Set ℓ} {B : Set ℓ'} (f : A → B) : 
  Set (ℓ ⊔ ℓ') where
  constructor mkisequiv
  field
    g : B → A 
    α : (f ○ g) ∼ id
    h : B → A
    β : (h ○ f) ∼ id

equiv₁ : ∀ {ℓ ℓ'} → {A : Set ℓ} {B : Set ℓ'} {f : A → B} → qinv f → isequiv f
equiv₁ (mkqinv qg qα qβ) = mkisequiv qg qα qg qβ
       
_≃_ : ∀ {ℓ ℓ'} (A : Set ℓ) (B : Set ℓ') → Set (ℓ ⊔ ℓ')
A ≃ B = Σ (A → B) isequiv

postulate 
  univalence : {A B : Set} → (A ≡ B) ≃ (A ≃ B)

------------------------------------------------------------------------------
-- Path and loop spaces

1-Path : {A : Set} → (a b : A) → Set
1-Path {A} a b = (a ≡ b)

2-Path : {A : Set} → (a b : A) (p q : 1-Path {A} a b) → Set
2-Path {A} a b p q = (p ≡ q)

Ω : (A : Set) → {a : A} → Set
Ω A {a} = 1-Path {A} a a

Ω² : (A : Set) → {a : A} → Set
Ω² A {a} = 2-Path {A} a a (refl a) (refl a)

-- Whiskering Lemmas
--     ___ p ___     ___ r ___
--   /           \ /           \
--  a     α⇓      b     β⇓     c
--   \           / \           /
--     --- q ---     --- s ---

wskR : {A : Set}
           {a b c : A}
           {p q : 1-Path {A} a b} →
           (α : 2-Path {A} a b p q) →
           (r : 1-Path {A} b c) → 
           (p ∘ r) ≡ (q ∘ r)
wskR {A} {a} {b} {c} {p} {q} α r = 
         (pathInd (λ {b} {c} r →
                     {p q : a ≡ b} →
                     (α : p ≡ q) →
                     2-Path {A} a c (p ∘ r) (q ∘ r))
                  (λ b {p} {q} α →
                    (p ∘ refl b) ≡⟨ ! (RU p) ⟩
                    p ≡⟨ α ⟩
                    q ≡⟨ RU q ⟩
                    (q ∘ refl b) ∎)
                 r)
                 α

wskL : {A : Set}
           {a b c : A}
           {r s : 1-Path {A} b c} →
           (q : 1-Path {A} a b) →
           (β : 2-Path {A} b c r s) →
           (q ∘ r) ≡ (q ∘ s)
wskL {A} {a} {b} {c} {r} {s} q β = 
  (pathInd (λ {a} {b} q →
              {r s : b ≡ c} →
              (α : r ≡ s) →
              2-Path {A} a c (q ∘ r) (q ∘ s))
           ((λ b {p} {q} β →
               (refl b ∘ p) ≡⟨ ! (LU p) ⟩
               p ≡⟨ β ⟩
               q ≡⟨ LU q ⟩
               (refl b ∘ q) ∎))
           q)
           β

_⋆_ : {A : Set}
      {a b c : A} 
      {p q : 1-Path {A} a b}
      {r s : 1-Path {A} b c}
      (α : 2-Path {A} a b p q) → 
      (β : 2-Path {A} b c r s) → 
      (p ∘ r) ≡ (q ∘ s)
_⋆_ {A} {a} {b} {c} {p} {q} {r} {s} α β = (wskR α r) ∘ (wskL q β)



Hcomp→compR1 : {A : Set}
              {a : A}
              (α : 2-Path {A} a a (refl a) (refl a)) →
              (wskR α (refl a)) ≡ (! (RU (refl a))) ∘ α ∘ (RU (refl a))
Hcomp→compR1 {A} {a} α = refl
                           (pathInd (λ {x} {y} _ → x ≡ y) refl
                            (pathInd (λ {x} {y} _ → (x₁ : a ≡ a) (x₂ : y ≡ x₁) → x ≡ x₁)
                             (λ x x₁ → pathInd (λ {x₂} {y} _ → x₂ ≡ y) refl) α (refl a)
                             (refl (refl a))))
                          


Hcomp→compL1 : {A : Set}
              {a : A}
              (β : 2-Path {A} a a (refl a) (refl a)) →
              (wskL (refl a) β) ≡ (! (LU (refl a))) ∘ β ∘ (LU (refl a))
Hcomp→compL1 {A} {a} β = refl
                           (pathInd (λ {x} {y} _ → x ≡ y) refl
                            (pathInd (λ {x} {y} _ → (x₁ : a ≡ a) (x₂ : y ≡ x₁) → x ≡ x₁)
                             (λ x x₁ → pathInd (λ {x₂} {y} _ → x₂ ≡ y) refl) β (refl a)
                             (refl (refl a))))

-- proof from pg 81
α⋆β≡α∘β : {A : Set}
             {a : A}
             (α : 2-Path {A} a a (refl a) (refl a)) →
             (β : 2-Path {A} a a (refl a) (refl a)) →
             α ⋆ β ≡ α ∘ β
α⋆β≡α∘β {A} {a} α β =

  α ⋆ β

  ≡⟨ refl (α ⋆ β) ⟩

  (wskR α ra) ∘ (wskL ra β)

  ≡⟨ refl ((!(refl ra) ∘ α ∘ (refl ra)) ∘ (wskL ra β)) ⟩

  (!(refl ra) ∘ (α ∘ (refl ra))) ∘ (wskL ra β)
    
  ≡⟨  ap (λ p → ((!(refl ra) ∘ p) ∘ (wskL ra β))) (! (RU α)) ⟩

  ((!(refl ra) ∘ α) ∘ (wskL ra β))

  ≡⟨ ap (λ p → (p ∘ (wskL ra β))) (! (LU α)) ⟩

  (α ∘ (wskL ra β))

  ≡⟨ refl (α ∘ (wskL ra β)) ⟩

  (α ∘ (!(refl ra) ∘ β ∘ (refl ra)))

  ≡⟨ ap (λ p → (α ∘ (!(refl ra) ∘ p))) (! (RU β)) ⟩

  (α ∘ (!(refl ra) ∘ β))

  ≡⟨ ap (λ p → (α ∘ p)) (! (LU β)) ⟩

  α ∘ β ∎
  where ra = (refl a)


_⋆'_ : {A : Set}
       {a b c : A} 
       {p q : 1-Path {A} a b}
       {r s : 1-Path {A} b c}
       (α : 2-Path {A} a b p q) → 
       (β : 2-Path {A} b c r s) → 
       (p ∘ r) ≡ (q ∘ s)
_⋆'_ {A} {a} {b} {c} {p} {q} {r} {s} α β = (wskL p β) ∘ (wskR α s)

α⋆'β≡β∘α : {A : Set}
           {a : A}
           (α : 2-Path {A} a a (refl a) (refl a)) →
           (β : 2-Path {A} a a (refl a) (refl a)) →
           α ⋆' β ≡ β ∘ α
α⋆'β≡β∘α {A} {a} α β =
  α ⋆' β

  ≡⟨ refl (α ⋆' β) ⟩

  (wskL ra β) ∘ (!(refl ra) ∘ (α ∘ (refl ra)))

  ≡⟨  ap (λ p → ((wskL ra β) ∘ (!(refl ra) ∘ p))) (! (RU α)) ⟩

  ((wskL ra β) ∘ (!(refl ra) ∘ α))

  ≡⟨ ap (λ p → ((wskL ra β) ∘ p)) (! (LU α)) ⟩

  ((wskL ra β) ∘ α)

  ≡⟨ refl ((wskL ra β) ∘ α) ⟩

  ((!(refl ra) ∘ β ∘ (refl ra)) ∘ α)

  ≡⟨ ap (λ p → ((!(refl ra) ∘ p) ∘ α)) (! (RU β)) ⟩

  ((!(refl ra) ∘ β) ∘ α)

  ≡⟨ ap (λ p → (p ∘ α)) (! (LU β)) ⟩
  
  β ∘ α ∎

  where ra = (refl a)

-- yuck lots of nested induction
α⋆β≡α⋆'β : {A : Set}
           {a : A}
           (α : 2-Path {A} a a (refl a) (refl a)) →
           (β : 2-Path {A} a a (refl a) (refl a)) → 
           α ⋆ β ≡ α ⋆' β
α⋆β≡α⋆'β {A} {a} α β =
  -- induction on α
  pathInd
    (λ α → α ⋆ β ≡ α ⋆' β)
    (λ p →
       -- induction on β
       pathInd
         (λ β → refl p ⋆ β ≡ refl p ⋆' β)
         (λ q →
            -- induction on p
            (pathInd
              (λ {a} {b} p → (c : A) → (q : b ≡ c) →
                 ((refl p ⋆ refl q) ≡ (refl p ⋆' refl q)))
                      (λ a d q →
                         -- induction on q
                         pathInd
                           (λ {a} {d} r →
                              ((refl (refl a) ⋆ refl r) ≡ (refl (refl a) ⋆' refl r)))
                           (λ a → refl (refl (refl a)))
                         q)
               p a q))
             β)
           α

eckmann-hilton : {A : Set} {a : A} (α β : Ω² A {a}) → α ∘ β ≡ β ∘ α 
eckmann-hilton {A} {a} α β =
  α ∘ β
  ≡⟨ ! (α⋆β≡α∘β α β) ⟩
  α ⋆ β
  ≡⟨ α⋆β≡α⋆'β α β ⟩
  α ⋆' β
  ≡⟨ α⋆'β≡β∘α α β ⟩
  β ∘ α ∎
------------------------------------------------------------------------------
