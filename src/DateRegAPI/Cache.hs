module DateRegAPI.Cache
  ( Cache(..)
  , CacheEntry(..)
  , newCache
  , clearCache
  , getCacheSize
  ) where

import Data.Time.Clock.POSIX
import qualified Data.Map.Strict as Map
import Control.Concurrent.MVar
import DateRegAPI.Types
import Data.ByteString.Lazy (ByteString)

data Cache = Cache
  { cacheLookup :: String -> IO (Maybe ByteString)
  , cacheInsert :: Int -> String -> ByteString -> IO ()
  , cacheClear :: IO ()
  , cacheSize :: IO Int
  }

data CacheEntry = CacheEntry
  { entryValue :: ByteString
  , entryTime :: Integer
  }

newCache :: Int -> Int -> IO Cache
newCache ttl maxSize = do
  ref <- newMVar (Map.empty :: Map.Map String CacheEntry)
  return Cache
    { cacheLookup = lookupCache ref
    , cacheInsert = insertCache ref
    , cacheClear = clearCache ref
    , cacheSize = getCacheSize ref
    }

lookupCache :: MVar (Map.Map String CacheEntry) -> String -> IO (Maybe ByteString)
lookupCache ref key = do
  now <- getCurrentTime
  cache <- readMVar ref
  case Map.lookup key cache of
    Just entry -> do
      let currentTime = round (utcTimeToPOSIXSeconds now) :: Integer
      if currentTime - entryTime entry < 3600  -- TTL check
        then return (Just (entryValue entry))
        else modifyMVar_ ref (return . Map.delete key) >> return Nothing
    Nothing -> return Nothing

insertCache :: MVar (Map.Map String CacheEntry) -> Int -> String -> ByteString -> IO ()
insertCache ref maxSize key value = do
  now <- getCurrentTime
  let currentTime = round (utcTimeToPOSIXSeconds now) :: Integer
      entry = CacheEntry value currentTime
  
  modifyMVar_ ref $ \cache -> do
    let newCache = Map.insert key entry cache
    return $ if Map.size newCache > maxSize
      then case Map.minViewWithKey newCache of
             Just ((minKey, _), rest) -> rest
             Nothing -> newCache
      else newCache

clearCache :: MVar (Map.Map String CacheEntry) -> IO ()
clearCache ref = modifyMVar_ ref (const (return Map.empty))

getCacheSize :: MVar (Map.Map String CacheEntry) -> IO Int
getCacheSize ref = Map.size <$> readMVar ref