{-# LANGUAGE DeriveGeneric #-}

module DateRegAPI.Types where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics

data Accuracy = Low | Medium | High
  deriving (Show, Eq, Generic)

instance ToJSON Accuracy
instance FromJSON Accuracy

data DateRegRequest
  = UserIdRequest Int
  | UsernameRequest Text
  deriving (Show, Eq)

data CacheMode
  = UseCache
  | BypassCache
  deriving (Show, Eq)