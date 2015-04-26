#!/usr/bin/env runhaskell
{-# LANGUAGE UnicodeSyntax, ScopedTypeVariables #-}
-- $ brew install ghc cabal-install
-- $ cabal install json base-unicode-symbols
-- $ curl -O https://gist.github.com/cfr/a7ce3793cdf8f17c6412/raw/JSON→Swift.hs
-- $ chmod +x JSON→Swift.hs
-- $ ./JSON→Swift.hs <file.json

module Main where

import Data.List (intercalate)
import Data.Char (toUpper)
import Data.Map (Map, mapKeys, member, fromList)
import Control.Arrow (second)
import qualified Data.Map.Strict as Map
import qualified Text.JSON (decode)
import Text.JSON hiding (decode)
import Prelude.Unicode
import Control.Monad.Unicode
import Control.Arrow.Unicode
import Control.Applicative.Unicode

jsonToSwiftURL = "http://j.mp/JSON-Swift_hs"

type Name = String
type Typename = String
data Type = Array Typename | Dictionary Typename Typename
          | Optional Typename | Typename
data Variable = Variable Name Type
data Function = Function Name [Variable] Type
data Record = Record Name [Variable]

type Def a = a → String
data Language = Language
    { var  ∷ Def Variable
    , fun  ∷ Def Function
    , typ  ∷ Def Type
    , rec  ∷ Def Record
    , etc  ∷ String
    }

type Spec = ([Record], [Function])

translator ∷ Language → Spec → String
translator (Language var fun typ rec etc) = (etc ⧺) ∘ tr where
  tr (recs, funs) = concatMap rec recs ⧺ concatMap fun funs


toSpec ∷ [Map String String] → Spec
toSpec = (map parseRec ⁂ map parseFun) ∘ span isRec where
  isRec = member '_' . mapKeys head
  parseRec ∷ Map String String → Record
  parseRec = undefined
  parseFun = undefined


swift ∷ Language
swift = undefined

translate ∷ JSValue → String
translate = translator swift ∘ toSpec ∘ processJSON

main = putStrLn ("// Generated with " ⧺ jsonToSwiftURL) ≫
       interact (translate ∘ decode) ≫ putStr "\n"

decode ∷ String → JSValue
decode = either error id ∘ resultToEither ∘ Text.JSON.decode

processJSON ∷ JSValue → [Map String String]
processJSON (JSArray a) = map (fromList ∘ map unpack ∘ fromJSObj) a where
  unpack (k, (JSString s)) = (k, fromJSString s)
  unpack _ = errType
  fromJSObj (JSObject obj) = fromJSObject obj
  fromJSObj _ = errType
  errType = error "Spec item should be map of type String: String"
processJSON _ = error $ "Root object should be array, see " ⧺ jsonToSwiftURL

