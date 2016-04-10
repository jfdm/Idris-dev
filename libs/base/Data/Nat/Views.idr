module Data.Nat.Views

ltAcc : (m : Nat) -> LT n m -> Accessible LT n
ltAcc Z x = absurd x 
ltAcc (S k) (LTESucc x) = Access (\val, p => ltAcc k (lteTransitive p x))

public export
data Half : Nat -> Type where
     HalfOdd : Half (S (n + n))
     HalfEven : Half (n + n)

public export
data HalfRec : Nat -> Type where
     HalfRecZ : HalfRec 0
     HalfRecEven : Lazy (HalfRec n) -> HalfRec (n + n)
     HalfRecOdd : Lazy (HalfRec n) -> HalfRec (S (n + n))

export
half : (n : Nat) -> Half n
half Z = HalfEven {n=0}
half (S k) with (half k)
  half (S (S (n + n))) | HalfOdd = rewrite plusSuccRightSucc (S n) n in
                                           HalfEven {n=S n}
  half (S (n + n)) | HalfEven = HalfOdd

halfRecFix : (n : Nat) -> ((m : Nat) -> LT m n -> HalfRec m) -> HalfRec n
halfRecFix Z hrec = HalfRecZ
halfRecFix (S k) hrec with (half k)
  halfRecFix (S (S (n + n))) hrec | HalfOdd 
       = rewrite plusSuccRightSucc (S n) n in 
                 HalfRecEven (hrec (S n) (LTESucc (LTESucc (lteAddRight _))))
  halfRecFix (S (n + n)) hrec | HalfEven 
       = HalfRecOdd (hrec n (LTESucc (lteAddRight _)))

export
halfRec : (n : Nat) -> HalfRec n
halfRec n = accInd halfRecFix n (ltAcc (S n) (LTESucc lteRefl))
