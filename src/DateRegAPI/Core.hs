{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveFunctor #-}

module DateRegAPI.Core
  ( DateRegAPI(..)
  , DateRegConfig(..)
  , defaultConfig
  , withDateRegAPI
  , DateRegM(..)
  , runDateRegM
  ) where

import Control.Monad.Reader
import Control.Monad.Except
import Control.Monad.Catch (MonadThrow)
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import Data.Default

import DateRegAPI.Types
import DateRegAPI.Cache
import DateRegAPI.Errors

data DateRegConfig = DateRegConfig
  { configToken :: String
  , configBaseUrl :: String
  , configTimeout :: Int
  , configCacheTtl :: Int
  , configCacheSize :: Int
  } deriving (Show, Eq)

instance Default DateRegConfig where
  def = defaultConfig

defaultConfig :: DateRegConfig
defaultConfig = DateRegConfig
  { configToken = ""
  , configBaseUrl = "https://api.datereg.pro/api/v1"
  , configTimeout = 30
  , configCacheTtl = 3600
  , configCacheSize = 128
  }

data DateRegAPI = DateRegAPI
  { apiConfig :: DateRegConfig
  , apiManager :: Manager
  , apiCache :: Cache
  }

newtype DateRegM a = DateRegM
  { runDateRegM :: ReaderT DateRegAPI (ExceptT DateRegError IO) a
  } deriving (Functor, Applicative, Monad, MonadReader DateRegAPI, MonadIO, MonadError DateRegError, MonadThrow)

withDateRegAPI :: DateRegConfig -> (DateRegAPI -> IO a) -> IO a
withDateRegAPI config action = do
  manager <- newManager tlsManagerSettings
  cache <- newCache (configCacheTtl config) (configCacheSize config)
  let api = DateRegAPI config manager cache
  action api
