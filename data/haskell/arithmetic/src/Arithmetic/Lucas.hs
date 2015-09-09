{- |
module: Arithmetic.Lucas
description: Lucas sequences
license: MIT

maintainer: Joe Leslie-Hurd <joe@gilith.com>
stability: provisional
portability: portable
-}
module Arithmetic.Lucas
where

import OpenTheory.Primitive.Natural
import qualified OpenTheory.Natural.Bits as Bits

import Arithmetic.Utility

advance :: (a -> a -> a) -> (a -> a -> a) -> a -> a -> a -> a -> a
advance sub mult p q x y = sub (mult p y) (mult q x)

sequence :: (a -> a -> a) -> (a -> a -> a) -> a -> a -> a -> a -> [a]
sequence sub mult p q =
    go
  where
    go x y = x : go y (advance sub mult p q x y)

uSequence :: a -> a -> (a -> a -> a) -> (a -> a -> a) -> a -> a -> [a]
uSequence zero one sub mult p q =
    Arithmetic.Lucas.sequence sub mult p q zero one

vSequence :: a -> (a -> a -> a) -> (a -> a -> a) -> a -> a -> [a]
vSequence two sub mult p q =
    Arithmetic.Lucas.sequence sub mult p q two p

williamsSequence :: a -> a -> (a -> a -> a) -> (a -> a -> a) -> a -> [a]
williamsSequence one two sub mult p = vSequence two sub mult p one

williamsNthExp ::
    a -> (a -> a -> a) -> (a -> a -> a) -> a -> Natural -> Natural -> a
williamsNthExp two sub mult p n k =
    if k == 0 then p
    else if n == 0 then two
    else functionPower nth k p
  where
    l = init (Bits.toList n)
    sq z = sub (mult z z) two
    nth v =
        w
      where
        (w,_) = foldr inc (v, sq v) l
        inc b (x,y) =
           if b then (z, sq y) else (sq x, z)
         where
           z = sub (mult x y) v

williamsNth :: a -> (a -> a -> a) -> (a -> a -> a) -> a -> Natural -> a
williamsNth two sub mult p n = williamsNthExp two sub mult p n 1
