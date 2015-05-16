{-# LANGUAGE UnicodeSyntax, RecordWildCards #-}
module Language where

import Control.Monad (join)
import Data.List (partition)

import Util -- specify

type Name = String
type Typename = String
data Type = Array Type | Dictionary { key ∷ Type, value ∷ Type }
          | Optional Type | Typename String deriving (Show, Eq)

data Variable = Variable Name Type (Maybe String) -- default value
                deriving (Show, Eq)
data Declaration = Record { name ∷ Name, vars ∷ [Variable]
                          , super ∷ Maybe Typename }
                 | Method { remote ∷ Name, returns ∷ Type
                          , name ∷ Name, args ∷ [Variable]
                          } deriving (Show, Eq)

data Language = Language { generate ∷ Declaration → String
                         , wrapEntities ∷ String → String
                         , wrapInterface ∷ String → String }

type Spec = [Declaration]

translator ∷ Language → Spec → (String, String)
translator (Language {..}) = partition isRec ⋙ gen ⋙ wrapEntities ⁂ wrapInterface
  where gen = join (⁂) (generate =≪)
        isRec Record {} = True
        isRec _ = False

atoms ∷ [Type]
atoms = map Typename ["String", "NSNumber"]
-- TODO: "Bool", "Int", "Float", "URL", "IntString"

primitives ∷ [Type]
primitives = foldr (=≪) atoms [opt, dict, opt, ap Array, opt]
  where ap = (take 2 ∘) ∘ iterate
        opt = ap Optional
        dict a = a : [Dictionary x a | x ← atoms]

primitive ∷ Type → Bool
primitive = (∈ primitives)

