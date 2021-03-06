module FiniteSet2 where

{-

  The FiniteSet type represents a finite set of natural numbers.
  It does so using a list of bits.
  This module is based on the Data.Fin.Subset module, but doesn't
  index the finite set type with the size of the full set. 

-}

open import Data.Empty using (⊥; ⊥-elim)
open import Data.Nat
open import Data.Nat.Properties using (∣n-n∣≡0; +-comm; ⊔-comm; ≤-refl; ≤-reflexive; ≤-step)
open Data.Nat.Properties.≤-Reasoning
  using (_≤⟨_⟩_)
  renaming (begin_ to begin≤_; _∎ to _QED)
open import Data.Bool
  using (Bool; true; false; T; _∨_; _∧_; if_then_else_)
open import Data.Bool.Properties
  using (∨-comm; ∨-assoc; ∧-comm; ∧-assoc; ∧-distribʳ-∨; ∧-distribˡ-∨)
open import Data.List
open import Data.Product
  using (_×_; Σ; Σ-syntax; ∃; ∃-syntax; proj₁; proj₂)
  renaming (_,_ to ⟨_,_⟩)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Unit using (⊤; tt)
open import Relation.Nullary using (Dec; yes; no; ¬_)
open import Relation.Binary.PropositionalEquality
   using (_≡_; _≢_; refl; sym; inspect; [_]; cong; subst)
open Relation.Binary.PropositionalEquality.≡-Reasoning
   using (begin_; _≡⟨⟩_; _≡⟨_⟩_; _∎)

abstract

{---------------------------------------------------
  Definitions
----------------------------------------------------}  

  data FiniteSetNE : Set {- non-empty -}
  data FiniteSet : Set
  
  data FiniteSet where
    ∅ : FiniteSet
    ne : FiniteSetNE → FiniteSet

  data FiniteSetNE where
    _∷_ : (b : Bool) → (if b then FiniteSet else FiniteSetNE) → FiniteSetNE

  ⁅_⁆ : ℕ → FiniteSet
  `⁅_⁆ : ℕ → FiniteSetNE
  `⁅ 0 ⁆ = true ∷ ∅
  `⁅ suc n ⁆ = false ∷ `⁅ n ⁆
  ⁅ x ⁆ = ne `⁅ x ⁆
  
  _∈_ : ℕ → FiniteSet → Set
  _`∈_ : ℕ → FiniteSetNE → Set
  x ∈ ∅ = ⊥
  x ∈ ne p = x `∈ p
  zero `∈ (b ∷ p) = T b
  suc x `∈ (true ∷ p) = x ∈ p
  suc x `∈ (false ∷ p) = x `∈ p

_∉_ : ℕ → FiniteSet → Set
x ∉ p = ¬ (x ∈ p)

_⊆_ : FiniteSet → FiniteSet → Set
p ⊆ q = ∀ {x} → x ∈ p → x ∈ q  

_`⊆_ : FiniteSetNE → FiniteSetNE → Set
p `⊆ q = ∀ {x} → x `∈ p → x `∈ q  

_⇔_ : Set → Set → Set
P ⇔ Q = (P → Q) × (Q → P)

abstract

  private

    non-empty⊈∅ : ∀ p → ¬ (ne p ⊆ ∅)
    non-empty⊈∅ (false ∷ p) =
      let IH = non-empty⊈∅ p in
      λ a → IH λ {x} x∈ → a {suc x} x∈
    non-empty⊈∅ (true ∷ p) =
      λ a → a {0} tt

  finite-set-ext :  ∀ p q
     → (p ≡ q)  ⇔  (p ⊆ q × q ⊆ p)
  finite-set-ne-ext :  ∀ p q
     → (p ≡ q)  ⇔  (p `⊆ q × q `⊆ p)
  finite-set-ext ∅ ∅ = ⟨ (λ x → ⟨ (λ x → x) , (λ x → x) ⟩) , (λ x → refl) ⟩
  finite-set-ext ∅ (ne p) =
      ⟨ (λ ()) , (λ x₁ → ⊥-elim (non-empty⊈∅ p (λ {x} → (proj₂ x₁){x}))) ⟩
  finite-set-ext (ne p) ∅ =
      ⟨ (λ ()) , (λ x₁ → ⊥-elim (non-empty⊈∅ p (λ {x} → (proj₁ x₁){x}))) ⟩
  finite-set-ext (ne p) (ne q) =
      ⟨ G , (λ pq,qp → cong ne ((proj₂ IH) pq,qp)) ⟩
      where
      IH : (p ≡ q) ⇔ ((p `⊆ q) × (q `⊆ p))
      IH = finite-set-ne-ext p q
      G : ne p ≡ ne q → (ne p ⊆ ne q) × (ne q ⊆ ne p)
      G refl = ⟨ (λ x → x) , (λ x → x) ⟩
      
  finite-set-ne-ext (false ∷ p) (false ∷ q) = ⟨ G , H ⟩
      where
      G : (false ∷ p) ≡ (false ∷ q)
        → ((false ∷ p) `⊆ (false ∷ q)) × ((false ∷ q) `⊆ (false ∷ p))
      G refl = ⟨ (λ {x} x∈ → x∈) , (λ {x} x∈ → x∈) ⟩
      H : ((false ∷ p) `⊆ (false ∷ q)) × ((false ∷ q) `⊆ (false ∷ p)) →
          (false ∷ p) ≡ (false ∷ q)
      H ⟨ pq , qp ⟩ =
        let IH = finite-set-ne-ext p q in
        cong (λ □ → false ∷ □)
            (proj₂ IH ⟨ (λ {x} x∈ → pq {suc x} x∈) ,
                        (λ {x} x∈ → qp {suc x} x∈) ⟩)
  finite-set-ne-ext (false ∷ p) (true ∷ q) =
      ⟨ (λ ()) , (λ { ⟨ pq , qp ⟩ → ⊥-elim (qp {0} tt) }) ⟩
  finite-set-ne-ext (true ∷ p) (false ∷ q) =
      ⟨ (λ ()) , (λ { ⟨ pq , qp ⟩ → ⊥-elim (pq {0} tt) }) ⟩
  finite-set-ne-ext (true ∷ p) (true ∷ q) = ⟨ G , H ⟩
      where
      G : (true ∷ p) ≡ (true ∷ q) →
          ((true ∷ p) `⊆ (true ∷ q)) × ((true ∷ q) `⊆ (true ∷ p))
      G refl = ⟨ (λ x → x) , (λ x → x) ⟩
      H : ((true ∷ p) `⊆ (true ∷ q)) × ((true ∷ q) `⊆ (true ∷ p)) →
          (true ∷ p) ≡ (true ∷ q)
      H ⟨ pq , qp ⟩ =
          let IH = finite-set-ext p q in
          cong (λ □ → true ∷ □) ( proj₂ IH ⟨ (λ {x} x∈ → pq {suc x} x∈) ,
                                             (λ {x} x∈ → qp {suc x} x∈) ⟩)

  _∪_ : FiniteSet → FiniteSet → FiniteSet
  _∪'_ : FiniteSetNE → FiniteSetNE → FiniteSetNE
  ∅ ∪ q = q
  ne p ∪ ∅ = ne p
  ne p ∪ ne q = ne (p ∪' q)

  (true ∷ p) ∪' (true ∷ q) = {!!}
  (true ∷ p) ∪' (false ∷ q) = {!!}
  (false ∷ p) ∪' (true ∷ q) = {!!}
  (false ∷ p) ∪' (false ∷ q) = {!!}

{-
  infix 1 _⇔_
  infix 4 _∈_ _∉_ _⊆_
  infixr 8 _-_
  infixr 7 _∩_
  infixr 6 _∪_




abstract

  _∪_ : FiniteSet → FiniteSet → FiniteSet
  [] ∪ ys = ys
  (x ∷ xs) ∪ [] = x ∷ xs
  (b ∷ xs) ∪ (c ∷ ys) = (b ∨ c) ∷ (xs ∪ ys)

  _∩_ : FiniteSet → FiniteSet → FiniteSet
  [] ∩ ys = []
  (x ∷ xs) ∩ [] = []
  (b ∷ xs) ∩ (c ∷ ys) = (b ∧ c) ∷ (xs ∩ ys)

  subtract : Bool → Bool → Bool
  subtract false b = false
  subtract true false = true
  subtract true true = false

  _-_ : FiniteSet → FiniteSet → FiniteSet
  [] - ys = []
  (x ∷ xs) - [] = x ∷ xs
  (b ∷ xs) - (c ∷ ys) = (subtract b c) ∷ (xs - ys)

  ∣_∣ : FiniteSet → ℕ
  ∣ [] ∣ = 0
  ∣ false ∷ p ∣ = ∣ p ∣
  ∣ true ∷ p ∣ = suc ∣ p ∣

{----------------------------------------------------
 Definitions of set operations in terms of membership
 ----------------------------------------------------}

  ⊥⇔⊥⊎⊥ : ⊥ ⇔ (⊥ ⊎ ⊥)
  ⊥⇔⊥⊎⊥ = ⟨ (λ ()) , (λ { (inj₁ x) → x ; (inj₂ x ) → x }) ⟩
  
  ∈∪ : ∀ x (p q : FiniteSet) → (x ∈ p ∪ q)  ⇔  (x ∈ p ⊎ x ∈ q)
  ∈∪ zero [] [] = ⊥⇔⊥⊎⊥
  ∈∪ zero [] (x ∷ q) =
      ⟨ inj₂ , (λ { (inj₁ x') → ⊥-elim x' ; (inj₂ x') → x' } ) ⟩
  ∈∪ zero (x ∷ p) [] = ⟨ inj₁ , G ⟩
      where
      G : T x ⊎ ⊥ → T x
      G (inj₁ x) = x
  ∈∪ zero (false ∷ p) (false ∷ q) = ⊥⇔⊥⊎⊥
  ∈∪ zero (false ∷ p) (true ∷ q) = ⟨ (λ x → inj₂ tt) , (λ x → tt) ⟩
  ∈∪ zero (true ∷ p) (x₁ ∷ q) = ⟨ (λ x → inj₁ tt) , (λ x → tt) ⟩
  ∈∪ (suc x) [] q =
      ⟨ (λ x₁ → inj₂ x₁) , (λ { (inj₁ x₁) → ⊥-elim x₁ ; (inj₂ x) → x }) ⟩
  ∈∪ (suc x) (x₁ ∷ p) [] =
      ⟨ (λ x₂ → inj₁ x₂) , (λ { (inj₁ x₁) → x₁ ; (inj₂ x) → ⊥-elim x }) ⟩
  ∈∪ (suc x) (x₁ ∷ p) (x₂ ∷ q) = ∈∪ x p q

  ∈p∪q→∈p⊎∈q : ∀{p q x} → x ∈ p ∪ q → x ∈ p ⊎ x ∈ q
  ∈p∪q→∈p⊎∈q {p}{q}{x} x∈pq = (proj₁ (∈∪ x p q)) x∈pq
  
  ∈∩ : ∀ x (p q : FiniteSet) → (x ∈ p ∩ q)  ⇔  (x ∈ p × x ∈ q)
  ∈∩ zero [] [] = ⟨ (λ x → ⟨ x , x ⟩) , proj₁ ⟩
  ∈∩ zero [] (x ∷ q) = ⟨ (λ ()) , proj₁ ⟩
  ∈∩ zero (x ∷ p) [] = ⟨ (λ ()) , proj₂ ⟩
  ∈∩ zero (false ∷ p) (x₁ ∷ q) = ⟨ (λ ()) , proj₁ ⟩
  ∈∩ zero (true ∷ p) (x₁ ∷ q) = ⟨ ⟨_,_⟩ tt , proj₂ ⟩
  ∈∩ (suc x) [] [] = ⟨ (λ x → ⟨ x , x ⟩) , proj₁ ⟩
  ∈∩ (suc x) [] (x₁ ∷ q) = ⟨ (λ ()) , (λ x₂ → proj₁ x₂) ⟩
  ∈∩ (suc x) (x₁ ∷ p) [] = ⟨ (λ x₂ → ⊥-elim x₂) , (λ x₂ → proj₂ x₂) ⟩
  ∈∩ (suc x) (x₁ ∷ p) (x₂ ∷ q) = ∈∩ x p q 

  ∈p∩q→∈p : ∀ {p q x} → x ∈ p ∩ q → x ∈ p
  ∈p∩q→∈p {p}{q}{x} x∈pq = proj₁ (proj₁ (∈∩ x p q) x∈pq)
  
  ∈p∩q→∈q : ∀ {p q x} → x ∈ p ∩ q → x ∈ q
  ∈p∩q→∈q {p}{q}{x} x∈pq = proj₂ (proj₁ (∈∩ x p q) x∈pq)

{---------------------------------------------------
  Properties
----------------------------------------------------}  

  ∉∅ : ∀{x} → x ∉ ∅
  ∉∅ {x} ()

  ∅⊆p : ∀{p} → ∅ ⊆ p
  ∅⊆p {p} ()

  ∣∅∣≡0 : ∣ ∅ ∣ ≡ 0  
  ∣∅∣≡0 = refl

  ∣⁅x⁆∣≡1 : ∀ x → ∣ ⁅ x ⁆ ∣ ≡ 1
  ∣⁅x⁆∣≡1 zero = refl
  ∣⁅x⁆∣≡1 (suc x) = ∣⁅x⁆∣≡1 x

  x∈⁅x⁆ : ∀ x → x ∈ ⁅ x ⁆
  x∈⁅x⁆ zero = tt
  x∈⁅x⁆ (suc x) = x∈⁅x⁆ x

  x∉⁅y⁆ : ∀ x y → x ≢ y → x ∉ ⁅ y ⁆
  x∉⁅y⁆ zero zero x∈ = ⊥-elim (x∈ refl)
  x∉⁅y⁆ (suc x) zero x∈ = λ z → z
  x∉⁅y⁆ zero (suc y) x∈ = λ z → z
  x∉⁅y⁆ (suc x) (suc y) x∈ = x∉⁅y⁆ x y λ z → x∈ (cong suc z)

  x∈⁅y⁆→x≡y : ∀ x y → x ∈ ⁅ y ⁆ → x ≡ y
  x∈⁅y⁆→x≡y zero zero x∈y = refl
  x∈⁅y⁆→x≡y (suc x) (suc y) x∈y = cong suc (x∈⁅y⁆→x≡y x y x∈y)

  ⊆-refl : ∀ {S} → S ⊆ S
  ⊆-refl {S} = λ z → z
  
  ⊆-trans : ∀ {S T U} → S ⊆ T → T ⊆ U → S ⊆ U
  ⊆-trans {S}{T}{U} = λ z z₁ {x} z₂ → z₁ (z z₂)

  p⊆q⇒∣p∣≤∣q∣ : ∀ {S T} → S ⊆ T → ∣ S ∣ ≤ ∣ T ∣
  p⊆q⇒∣p∣≤∣q∣ {[]} {[]} S⊆T = z≤n
  p⊆q⇒∣p∣≤∣q∣ {[]} {false ∷ T} S⊆T = p⊆q⇒∣p∣≤∣q∣ {[]}{T} λ {x} ()
  p⊆q⇒∣p∣≤∣q∣ {[]} {true ∷ T} S⊆T = z≤n
  p⊆q⇒∣p∣≤∣q∣ {false ∷ S} {[]} S⊆T =
      p⊆q⇒∣p∣≤∣q∣ {S} {[]} λ {x} x∈ → S⊆T {suc x} x∈
  p⊆q⇒∣p∣≤∣q∣ {true ∷ S} {[]} S⊆T = ⊥-elim (S⊆T {0} tt)
  p⊆q⇒∣p∣≤∣q∣ {false ∷ S} {false ∷ T} S⊆T =
      p⊆q⇒∣p∣≤∣q∣ {S} {T} λ {x} x∈ → S⊆T {suc x} x∈
  p⊆q⇒∣p∣≤∣q∣ {false ∷ S} {true ∷ T} S⊆T =
      let IH = p⊆q⇒∣p∣≤∣q∣ {S} {T} λ {x} x∈ → S⊆T {suc x} x∈ in
      ≤-step IH
  p⊆q⇒∣p∣≤∣q∣ {true ∷ S} {false ∷ T} S⊆T = ⊥-elim (S⊆T {0} tt)
  p⊆q⇒∣p∣≤∣q∣ {true ∷ S} {true ∷ T} S⊆T =
      s≤s (p⊆q⇒∣p∣≤∣q∣ {S} {T} λ {x} x∈ → S⊆T {suc x} x∈)

  ∣p∪q∣≤∣p∣+∣q∣ : ∀{p q} → ∣ p ∪ q ∣ ≤ ∣ p ∣ + ∣ q ∣
  ∣p∪q∣≤∣p∣+∣q∣ {[]} {q} = ≤-refl
  ∣p∪q∣≤∣p∣+∣q∣ {x ∷ p} {[]} rewrite +-comm ∣ x ∷ p ∣ 0 = ≤-refl
  ∣p∪q∣≤∣p∣+∣q∣ {false ∷ p} {false ∷ q} = ∣p∪q∣≤∣p∣+∣q∣ {p} {q}
  ∣p∪q∣≤∣p∣+∣q∣ {false ∷ p} {true ∷ q}
      rewrite +-comm ∣ p ∣ (suc ∣ q ∣)
      | +-comm ∣ q ∣ ∣ p ∣ = s≤s (∣p∪q∣≤∣p∣+∣q∣ {p} {q})
  ∣p∪q∣≤∣p∣+∣q∣ {true ∷ p} {false ∷ q} = s≤s (∣p∪q∣≤∣p∣+∣q∣ {p} {q})
  ∣p∪q∣≤∣p∣+∣q∣ {true ∷ p} {true ∷ q}
      rewrite +-comm ∣ p ∣ (suc ∣ q ∣)
      | +-comm ∣ q ∣ ∣ p ∣ = s≤s (≤-step (∣p∪q∣≤∣p∣+∣q∣ {p} {q}))

  {------------------------
   Identity Laws
   ------------------------}
   
  p∪∅≡p : ∀ p → p ∪ ∅ ≡ p
  p∪∅≡p [] = refl
  p∪∅≡p (x ∷ p) = refl

  ∅∪p≡p : ∀ p → ∅ ∪ p ≡ p
  ∅∪p≡p [] = refl
  ∅∪p≡p (x ∷ p) = refl

  {------------------------
   Domination Laws
   ------------------------}

  {------------------------
   Idempotent Laws
   ------------------------}

  ∪-idem : ∀ p → p ∪ p ≡ p
  ∪-idem [] = refl
  ∪-idem (false ∷ p) rewrite ∪-idem p = refl
  ∪-idem (true ∷ p) rewrite ∪-idem p = refl

  ∩-idem : ∀ p → p ∩ p ≡ p
  ∩-idem [] = refl
  ∩-idem (false ∷ p) rewrite ∩-idem p = refl
  ∩-idem (true ∷ p) rewrite ∩-idem p = refl

  {------------------------
   Complementation Laws
   ------------------------}

  p-p⊆∅ : ∀ p → p - p ⊆ ∅
  p-p⊆∅ [] ()
  p-p⊆∅ (false ∷ p) {suc x} x∈ = p-p⊆∅ p {x} x∈
  p-p⊆∅ (true ∷ p) {suc x} x∈ = p-p⊆∅ p {x} x∈

  ∅⊆p-p : ∀ p → ∅ ⊆ p - p
  ∅⊆p-p p {x} ()
  
  {------------------------
   Commutative Laws
   ------------------------}

  ∪-comm : ∀ p q → p ∪ q ≡ q ∪ p
  ∪-comm [] [] = refl
  ∪-comm [] (x ∷ q) = refl
  ∪-comm (x ∷ p) [] = refl
  ∪-comm (b ∷ p) (c ∷ q)
      rewrite ∨-comm b c | ∪-comm p q = refl

  ∩-comm : ∀ p q → p ∩ q ≡ q ∩ p
  ∩-comm [] [] = refl
  ∩-comm [] (b ∷ q) = refl
  ∩-comm (b ∷ p) [] = refl
  ∩-comm (b ∷ p) (c ∷ q)
      rewrite ∧-comm b c | ∩-comm p q = refl

  {------------------------
   Associative Laws
   ------------------------}

  ∪-assoc : ∀ p q r → (p ∪ q) ∪ r ≡ p ∪ (q ∪ r)
  ∪-assoc [] q r = refl
  ∪-assoc (a ∷ p) [] r = refl
  ∪-assoc (a ∷ p) (b ∷ q) [] = refl
  ∪-assoc (a ∷ p) (b ∷ q) (c ∷ r)
      rewrite ∨-assoc a b c
      | ∪-assoc p q r = refl

  ∩-assoc : ∀ p q r → (p ∩ q) ∩ r ≡ p ∩ (q ∩ r)
  ∩-assoc [] q r = refl
  ∩-assoc (a ∷ p) [] r = refl
  ∩-assoc (a ∷ p) (b ∷ q) [] = refl
  ∩-assoc (a ∷ p) (b ∷ q) (c ∷ r)
      rewrite ∧-assoc a b c
      | ∩-assoc p q r = refl

  {-------------------------
   Distributive Laws
   -------------------------}

  
  ∪-distrib-∩ : ∀{A B C} → (A ∪ B) ∩ C ≡ (A ∩ C) ∪ (B ∩ C)
  ∪-distrib-∩ {[]} {[]} {[]} = refl
  ∪-distrib-∩ {[]} {[]} {x ∷ C} = refl
  ∪-distrib-∩ {[]} {x ∷ B} {C} = refl
  ∪-distrib-∩ {x ∷ A} {[]} {[]} = refl
  ∪-distrib-∩ {false ∷ A} {[]} {x₁ ∷ C} = refl
  ∪-distrib-∩ {true ∷ A} {[]} {x₁ ∷ C} = refl
  ∪-distrib-∩ {x ∷ A} {x₁ ∷ B} {[]} = refl
  ∪-distrib-∩ {x ∷ A} {y ∷ B} {z ∷ C}
      rewrite ∧-distribʳ-∨ z x y
      | ∪-distrib-∩ {A}{B}{C} = refl

  ∪-distribˡ-∩ : ∀{A B C} → A ∩ (B ∪ C) ≡ (A ∩ B) ∪ (A ∩ C)
  ∪-distribˡ-∩ {[]} {B} {C} = refl
  ∪-distribˡ-∩ {x ∷ A} {[]} {C} = refl
  ∪-distribˡ-∩ {x ∷ A} {x₁ ∷ B} {[]} = refl
  ∪-distribˡ-∩ {x ∷ A} {y ∷ B} {z ∷ C}
      rewrite ∧-distribˡ-∨ x y z
      | ∪-distribˡ-∩ {A}{B}{C} = refl
  
  distrib-∨-sub : ∀ a b c → subtract a c ∨ subtract b c ≡ subtract (a ∨ b) c
  distrib-∨-sub false b c = refl
  distrib-∨-sub true false false = refl
  distrib-∨-sub true false true = refl
  distrib-∨-sub true true false = refl
  distrib-∨-sub true true true = refl

  distrib-∪- : ∀ p q r → (p - r) ∪ (q - r) ≡ (p ∪ q) - r
  distrib-∪- [] [] r = refl
  distrib-∪- [] (x ∷ q) r = refl
  distrib-∪- (x ∷ p) [] r = p∪∅≡p _
  distrib-∪- (a ∷ p) (b ∷ q) [] = refl
  distrib-∪- (a ∷ p) (b ∷ q) (c ∷ r)
      rewrite distrib-∪- p q r | distrib-∨-sub a b c = refl

  {-------------
   Uncategorized
   -------------}

  p⊆p∪q : (p q : FiniteSet) → p ⊆ p ∪ q
  p⊆p∪q p [] x∈p rewrite ∪-comm p [] = x∈p
  p⊆p∪q (true ∷ p) (c ∷ q) {zero} x∈p = tt
  p⊆p∪q (b ∷ p) (c ∷ q) {suc x} x∈p = p⊆p∪q p q x∈p

  q⊆p∪q : ∀ (p q : FiniteSet) → q ⊆ p ∪ q
  q⊆p∪q [] (c ∷ q) {x} x∈q = x∈q
  q⊆p∪q (false ∷ p) (true ∷ q) {zero} x∈q = tt
  q⊆p∪q (true ∷ p) (true ∷ q) {zero} x∈q = tt
  q⊆p∪q (b ∷ p) (c ∷ q) {suc x} x∈q = q⊆p∪q p q {x} x∈q

  p⊆q→p⊆q∪r : ∀ p q r → p ⊆ q → p ⊆ q ∪ r
  p⊆q→p⊆q∪r p q r pq = ⊆-trans {p}{q}{q ∪ r} pq (p⊆p∪q q r)

  p⊆r→p⊆q∪r : ∀ p q r → p ⊆ r → p ⊆ q ∪ r
  p⊆r→p⊆q∪r p q r pr = ⊆-trans {p}{r}{q ∪ r} pr (q⊆p∪q q r)


  ∪-lub : ∀ {p q r } → p ⊆ r → q ⊆ r → p ∪ q ⊆ r
  ∪-lub {p}{q}{r} pr qr {x} x∈p∪q
      with ∈p∪q→∈p⊎∈q {p}{q}{x} x∈p∪q
  ... | inj₁ x∈p = pr x∈p
  ... | inj₂ x∈q = qr x∈q

  p⊆r→q⊆r→p∪q⊆r : ∀ p q r → p ⊆ r → q ⊆ r → p ∪ q ⊆ r
  p⊆r→q⊆r→p∪q⊆r p q r = ∪-lub {p}{q}{r}

  p⊆r→q⊆s→p∪q⊆r∪s : ∀{p q r s} → p ⊆ r → q ⊆ s → p ∪ q ⊆ r ∪ s
  p⊆r→q⊆s→p∪q⊆r∪s {p}{q}{r}{s} pr qs {x} x∈p∪q
      with ∈p∪q→∈p⊎∈q {p}{q}{x} x∈p∪q
  ... | inj₁ x∈p = (p⊆p∪q r s) (pr x∈p)
  ... | inj₂ x∈q = (q⊆p∪q r s) (qs x∈q)

  {-------------------------------
    Inequational reasoning about ⊆ 
   -------------------------------}

  infix  1 begin⊆_
  infixr 2 _⊆⟨_⟩_
  infix  3 _■

  begin⊆_ : ∀{p q} → p ⊆ q → p ⊆ q
  begin⊆_ pq = pq

  _⊆⟨_⟩_ : ∀ p {q r} → p ⊆ q → q ⊆ r → p ⊆ r
  _⊆⟨_⟩_ p {q}{r} p⊆q q⊆r = ⊆-trans {p}{q}{r} p⊆q q⊆r

  _■ : ∀ p → p ⊆ p
  _■ p = ⊆-refl {p}

  ⊆-reflexive : ∀ {p q} → p ≡ q → p ⊆ q
  ⊆-reflexive {p} refl = ⊆-refl {p}


  p-∅≡p : ∀ p → p - ∅ ≡ p
  p-∅≡p [] = refl
  p-∅≡p (x ∷ p) = refl

  ⁅y⁆-⁅x⁆≡⁅y⁆ : ∀ {x y } → x ≢ y → ⁅ y ⁆ - ⁅ x ⁆ ≡ ⁅ y ⁆
  ⁅y⁆-⁅x⁆≡⁅y⁆ {zero} {zero} xy = ⊥-elim (xy refl)
  ⁅y⁆-⁅x⁆≡⁅y⁆ {suc x} {zero} xy = refl
  ⁅y⁆-⁅x⁆≡⁅y⁆ {zero} {suc y} xy = cong (λ □ → false ∷ □) (p-∅≡p _)
  ⁅y⁆-⁅x⁆≡⁅y⁆ {suc x} {suc y} xy =
      cong (λ □ → false ∷ □) (⁅y⁆-⁅x⁆≡⁅y⁆ λ z → xy (cong suc z))

  ⁅y⁆∩⁅x⁆⊆∅ : ∀ x y → x ≢ y → ⁅ y ⁆ ∩ ⁅ x ⁆ ⊆ ∅
  ⁅y⁆∩⁅x⁆⊆∅ zero zero xy = ⊥-elim (xy refl)
  ⁅y⁆∩⁅x⁆⊆∅ zero (suc y) xy {z}
       with y
  ... | 0
      with z
  ... | 0 = λ z → z
  ... | suc z' = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ zero (suc y) xy {0} | suc y' = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ zero (suc y) xy {suc z} | suc y' = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ (suc x) zero xy {zero} = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ (suc x) zero xy {suc z} = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ (suc x) (suc y) xy {zero} = λ z → z
  ⁅y⁆∩⁅x⁆⊆∅ (suc x) (suc y) xy {suc z} =
      (⁅y⁆∩⁅x⁆⊆∅ x y λ z → xy (cong suc z)) {z}

  x∈p→⁅x⁆∩p≡⁅x⁆ : ∀ x p → x ∈ p → ⁅ x ⁆ ∩ p ≡ ⁅ x ⁆
  x∈p→⁅x⁆∩p≡⁅x⁆ zero (true ∷ p) x∈p = refl
  x∈p→⁅x⁆∩p≡⁅x⁆ (suc x) (_ ∷ p) x∈p =
      cong (λ □ → false ∷ □) (x∈p→⁅x⁆∩p≡⁅x⁆ x p x∈p)

  ∪-identityʳ₁ : ∀ p → p ⊆ p ∪ ∅
  ∪-identityʳ₁ [] ()
  ∪-identityʳ₁ (b ∷ p) {x} x∈ = x∈
  
  p∩r⊆∅→p-r≡p : ∀ p r
     → p ∩ r ⊆ ∅
     → p - r ≡ p
  p∩r⊆∅→p-r≡p [] r p∩r = refl
  p∩r⊆∅→p-r≡p (x ∷ p) [] p∩r = refl
  p∩r⊆∅→p-r≡p (false ∷ p) (_ ∷ r) p∩r =
    let IH = p∩r⊆∅→p-r≡p p r (λ {z} z∈ → p∩r {suc z} z∈) in
    cong (λ □ → false ∷ □) IH
  p∩r⊆∅→p-r≡p (true ∷ p) (false ∷ r) p∩r =
    let IH = p∩r⊆∅→p-r≡p p r (λ {z} z∈ → p∩r {suc z} z∈) in
    cong (λ □ → true ∷ □) IH
  p∩r⊆∅→p-r≡p (true ∷ p) (true ∷ r) p∩r = ⊥-elim (p∩r {0} tt)

  distrib-∪-2 : ∀ p q r
     → p ∩ r ⊆ ∅
     → p ∪ (q - r) ≡ (p ∪ q) - r
  distrib-∪-2 [] q r p∩r = refl
  distrib-∪-2 (x ∷ p) [] [] p∩r = refl
  distrib-∪-2 (false ∷ p) [] (b ∷ r) p∩r =
      cong (λ □ → false ∷ □) (sym (p∩r⊆∅→p-r≡p p r (λ {x} z → p∩r {suc x} z)))
  distrib-∪-2 (true ∷ p) [] (false ∷ r) p∩r =
      cong (λ □ → true ∷ □) (sym (p∩r⊆∅→p-r≡p p r (λ {x} z → p∩r {suc x} z)))
  distrib-∪-2 (true ∷ p) [] (true ∷ r) p∩r = ⊥-elim (p∩r {0} tt)
  distrib-∪-2 (a ∷ p) (b ∷ q) [] p∩r = refl
  distrib-∪-2 (false ∷ p) (b ∷ q) (c ∷ r) p∩r =
      let IH = distrib-∪-2 p q r λ {x} x∈ → p∩r {suc x} x∈ in
      cong (λ □ → subtract b c ∷ □) IH
  distrib-∪-2 (true ∷ p) (b ∷ q) (false ∷ r) p∩r =
      let IH = distrib-∪-2 p q r λ {x} x∈ → p∩r {suc x} x∈ in
      cong (λ □ → true ∷ □) IH
  distrib-∪-2 (true ∷ p) (b ∷ q) (true ∷ r) p∩r = ⊥-elim (p∩r {0} tt)

  ∣p-x∣<∣p∪x∣ : ∀ p x → ∣ (p - ⁅ x ⁆) ∣ < ∣ p ∪ ⁅ x ⁆ ∣
  ∣p-x∣<∣p∪x∣ [] x
      rewrite ∣⁅x⁆∣≡1 x = ≤-refl
  ∣p-x∣<∣p∪x∣ (false ∷ p) zero
      rewrite p-∅≡p p = s≤s (p⊆q⇒∣p∣≤∣q∣ {p}{p ∪ ∅} (∪-identityʳ₁ p))
  ∣p-x∣<∣p∪x∣ (true ∷ p) zero
      rewrite p-∅≡p p = s≤s (p⊆q⇒∣p∣≤∣q∣ {p}{p ∪ ∅} (∪-identityʳ₁ p))  
  ∣p-x∣<∣p∪x∣ (false ∷ p) (suc x) = ∣p-x∣<∣p∪x∣ p x
  ∣p-x∣<∣p∪x∣ (true ∷ p) (suc x) = s≤s (∣p-x∣<∣p∪x∣ p x)

  p∪q⊆∅→p⊆∅×q⊆∅ : ∀ p q → p ∪ q ⊆ ∅ → p ⊆ ∅ × q ⊆ ∅
  p∪q⊆∅→p⊆∅×q⊆∅ [] q p∪q⊆∅ = ⟨ (λ {x} z → z) , p∪q⊆∅ ⟩
  p∪q⊆∅→p⊆∅×q⊆∅ (b ∷ p) [] p∪q⊆∅ = ⟨ (λ {x} → p∪q⊆∅ {x}) , (λ {x} z → z) ⟩
  p∪q⊆∅→p⊆∅×q⊆∅ (false ∷ p) (false ∷ q) p∪q⊆∅ =
      ⟨ (λ {x} → G1 {x}) , (λ {x} → G2 {x}) ⟩
      where
      IH : p ⊆ ∅ × q ⊆ ∅
      IH = p∪q⊆∅→p⊆∅×q⊆∅ p q λ {x} x∈pq → p∪q⊆∅ {suc x} x∈pq
      G1 : false ∷ p ⊆ ∅
      G1 {suc x} = proj₁ IH
      G2 : false ∷ q ⊆ ∅
      G2 {suc x} = proj₂ IH
  p∪q⊆∅→p⊆∅×q⊆∅ (false ∷ p) (true ∷ q) p∪q⊆∅ = ⊥-elim (p∪q⊆∅ {0} tt)
  p∪q⊆∅→p⊆∅×q⊆∅ (true ∷ p) (c ∷ q) p∪q⊆∅ = ⊥-elim (p∪q⊆∅ {0} tt)
-}
