{- |
module: Arithmetic.Polynomial
description: Polynomial arithmetic
license: MIT

maintainer: Joe Leslie-Hurd <joe@gilith.com>
stability: provisional
portability: portable
-}
module Arithmetic.Polynomial
where

import OpenTheory.Primitive.Natural
import OpenTheory.List
import Data.List as List
import Data.Maybe as Maybe

import Arithmetic.Utility
import qualified Arithmetic.Ring as Ring

data Polynomial a =
     Polynomial
       {carrier :: Ring.Ring a,
        coefficients :: [a]}

instance (Eq a, Show a) => Show (Polynomial a) where
  show p =
      if null ps then "0"
      else List.intercalate " + " ps
    where
      r = carrier p
      z = Ring.zero r
      o = Ring.one r
      ps = showC 0 (coefficients p)

      showC _ [] = []
      showC k (x : xs) = showM x k ++ showC (k + 1) xs

      showM x k =
          if x == z then []
          else [(if k /= 0 && x == o then "" else show x) ++
                (if k == 0 then ""
                 else ("x" ++ (if k == 1 then "" else "^" ++ show k)))]

fromCoefficients :: Eq a => Ring.Ring a -> [a] -> Polynomial a
fromCoefficients r cs =
    Polynomial
      {carrier = r,
       coefficients = norm cs}
  where
    z = Ring.zero r

    zcons x xs = if null xs && x == z then [] else x : xs

    norm [] = []
    norm (x : xs) = zcons x (norm xs)

zero :: Ring.Ring a -> Polynomial a
zero r =
    Polynomial
      {carrier = r,
       coefficients = []}

isZero :: Polynomial a -> Bool
isZero = null . coefficients

constant :: Eq a => Ring.Ring a -> a -> Polynomial a
constant r x = fromCoefficients r [x]

destConstant :: Polynomial a -> Maybe a
destConstant p =
    case coefficients p of
      [] -> Just (Ring.zero r)
      [c] -> Just c
      _ -> Nothing
  where
    r = carrier p

isConstant :: Polynomial a -> Bool
isConstant = Maybe.isJust . destConstant

fromNatural :: Eq a => Ring.Ring a -> Natural -> Polynomial a
fromNatural r = constant r . Ring.fromNatural r

degree :: Polynomial a -> Natural
degree = naturalLength . coefficients

-- Horner's method
evaluate :: Polynomial a -> a -> a
evaluate p x =
    foldr eval (Ring.zero r) (coefficients p)
  where
    r = carrier p
    eval c z = Ring.add r c (Ring.multiply r x z)

addCoefficients :: Ring.Ring a -> [a] -> [a] -> [a]
addCoefficients r =
    addc
  where
    addc [] ys = ys
    addc xs [] = xs
    addc (x : xs) (y : ys) = Ring.add r x y : addc xs ys

add :: Eq a => Polynomial a -> Polynomial a -> Polynomial a
add p q =
    fromCoefficients r (addCoefficients r ps qs)
  where
    r = carrier p
    ps = coefficients p
    qs = coefficients q

negate :: Polynomial a -> Polynomial a
negate p =
    Polynomial
      {carrier = r,
       coefficients = map (Ring.negate r) pl}
  where
    r = carrier p
    pl = coefficients p

multiply :: Eq a => Polynomial a -> Polynomial a -> Polynomial a
multiply p q =
    case coefficients q of
      [] -> zero r
      qh : qt ->
          fromCoefficients r (foldr multc [] (coefficients p))
        where
          z = Ring.zero r

          madd pc cs = addCoefficients r (map (Ring.multiply r pc) qt) cs

          multc pc cs =
              if pc == z then z : cs
              else Ring.multiply r pc qh : madd pc cs
  where
    r = carrier p

invert :: Polynomial a -> Maybe (Polynomial a)
invert p =
    case coefficients p of
      [x] -> case Ring.invert r x of
               Nothing -> Nothing
               Just y -> Just (Polynomial {carrier = r, coefficients = [y]})
      _ -> Nothing
  where
    r = carrier p

ring :: Eq a => Ring.Ring a -> Ring.Ring (Polynomial a)
ring r =
    Ring.Ring {Ring.fromNatural = fromNatural r,
               Ring.add = add,
               Ring.negate = Arithmetic.Polynomial.negate,
               Ring.multiply = multiply,
               Ring.invert = invert}