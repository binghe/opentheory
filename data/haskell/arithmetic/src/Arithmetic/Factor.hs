{- |
module: Arithmetic.Factor
description: Factorized natural numbers
license: MIT

maintainer: Joe Leslie-Hurd <joe@gilith.com>
stability: provisional
portability: portable
-}
module Arithmetic.Factor
where

import qualified Data.List as List
import qualified Data.Map as Map
import OpenTheory.Primitive.Natural
import qualified OpenTheory.Natural.Bits as Bits
import qualified OpenTheory.Primitive.Random as Random

import Arithmetic.Prime
import Arithmetic.Random
import Arithmetic.Utility

newtype Factor = Factor {unFactor :: Map.Map Natural Natural}

one :: Factor
one = Factor {unFactor = Map.empty}

isOne :: Factor -> Bool
isOne = Map.null . unFactor

primePower :: Natural -> Natural -> Factor
primePower p k = if k == 0 then one else Factor {unFactor = Map.singleton p k}

prime :: Natural -> Factor
prime p = primePower p 1

multiply :: Factor -> Factor -> Factor
multiply f1 f2 =
    Factor {unFactor = Map.unionWith (+) m1 m2}
  where
    m1 = unFactor f1
    m2 = unFactor f2

exp :: Factor -> Natural -> Factor
exp f n =
    if n == 0 then one
    else if n == 1 then f
    else Factor {unFactor = Map.map ((*) n) (unFactor f)}

gcd :: Factor -> Factor -> Factor
gcd f1 f2 =
    Factor {unFactor = Map.intersectionWith min m1 m2}
  where
    m1 = unFactor f1
    m2 = unFactor f2

trialDivision :: [Natural] -> Natural -> (Factor,Natural)
trialDivision =
    go
  where
    go [] n = (one,n)
    go (p : ps) n =
        if n <= 1 then (one,n)
        else (multiply f (primePower p r), m)
      where
        (r,s) = factorOut p n
        (f,m) = go ps s

multiplicative :: (Natural -> Natural -> a) -> (a -> a -> a) -> a -> Factor -> a
multiplicative pkA multA oneA f =
    case Map.foldrWithKey inc Nothing (unFactor f) of
      Nothing -> oneA
      Just x -> x
  where
    inc p k acc = mult (pkA p k) acc
    mult x Nothing = Just x
    mult x (Just y) = Just (multA x y)

toNatural :: Factor -> Natural
toNatural = multiplicative (^) (*) 1

totient :: Factor -> Natural
totient =
    multiplicative tot (*) 1
  where
    tot p k = (p ^ (k - 1)) * (p - 1)

instance Show Factor where
  show =
      multiplicative showPK (++) "1"
    where
      showPK p k = show p ++ showExp k
      showExp k = if k == 1 then "" else "^" ++ show k

factorPower :: Natural -> Natural -> Maybe (Natural,Natural)
factorPower pmin n =
    go n primes
  where
    go s (p : ps) =
        if t < pmin then Nothing
        else if t ^ p == n then Just (t,p)
        else go t ps
      where
        t = bisect 1 s

        bisect l u =
            if m == l then l
            else if m ^ p <= n then bisect m u
            else bisect l m
          where
            m = (l + u) `div` 2

factor :: Natural -> (Natural -> Random.Random -> Maybe Natural) ->
          Natural -> Random.Random -> Maybe Factor
factor k ff =
    trial
  where
    (ptrials,pmin) = (init ps, last ps)
      where
        ps = take (fromIntegral (k + 1)) primes

    trial n rnd =
        if m == 1 then Just f
        else mmult (Just f) (go m rnd)
      where
        (f,m) = trialDivision ptrials n

    go n rnd =
        if isPrime n r1 then Just (prime n)
        else
          case factorPower pmin n of
            Just (m,i) -> mexp (go m r2) i
            Nothing -> case ff n r2 of
                         Nothing -> Nothing
                         Just p -> mmult (go p r3) (go (n `div` p) r4)
      where
        (r1,r24) = Random.split rnd
        (r2,r34) = Random.split r24
        (r3,r4) = Random.split r34

    mmult (Just f1) (Just f2) = Just (multiply f1 f2)
    mmult _ _ = Nothing

    mexp (Just f) i = Just (Arithmetic.Factor.exp f i)
    mexp Nothing _ = Nothing

randomRSA :: Natural -> Random.Random -> Factor
randomRSA w =
    randomFilter check gen
  where
    check f = Bits.width (toNatural f) == w

    gen rnd =
        multiply (prime p1) (prime p2)
      where
        p1 = randomPrime w1 r1
        p2 = randomPrime w2 r2
        (r1,r2) = Random.split rnd

    w1 = w `div` 2
    w2 = w - w1
