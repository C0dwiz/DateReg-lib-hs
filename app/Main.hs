{-# LANGUAGE OverloadedStrings #-}

module Main where

import DateRegAPI
import Data.Default
import Control.Monad.Reader (runReaderT)
import Control.Monad.Except (runExceptT)

main :: IO ()
main = do
  let config = def
        { configToken = "your-token-here"
        }
  
  putStrLn "Starting DateReg API Example..."
  
  withDateRegAPI config $ \api -> do
    -- Пример 1: Получение даты регистрации по ID
    putStrLn "\n1. Getting creation date by user ID:"
    result1 <- runExceptT $ runReaderT (runDateRegM (getCreationDateSmart 1477417142)) api
    case result1 of
      Left err -> putStrLn $ "Error: " ++ show err
      Right response -> do
        putStrLn $ "User ID: " ++ show (cdrUserId response)
        putStrLn $ "Creation Date: " ++ show (cdrCreationDate response)
        putStrLn $ "Accuracy: " ++ show (cdrAccuracyPercent response) ++ "%"
    
    -- Пример 2: Получение даты регистрации по username
    putStrLn "\n2. Getting creation date by username:"
    result2 <- runExceptT $ runReaderT (runDateRegM (getCreationDateByUsername "liteapi")) api
    case result2 of
      Left err -> putStrLn $ "Error: " ++ show err
      Right response -> do
        putStrLn $ "Username: " ++ show (cdburUsername response)
        putStrLn $ "User ID: " ++ show (cdburUserId response)
        putStrLn $ "Creation Date: " ++ show (cdburCreationDate response)
    
    -- Пример 3: Разрешение username
    putStrLn "\n3. Resolving username:"
    result3 <- runExceptT $ runReaderT (runDateRegM (resolveUsername "liteapi")) api
    case result3 of
      Left err -> putStrLn $ "Error: " ++ show err
      Right userInfo -> do
        putStrLn $ "User ID: " ++ show (rurId userInfo)
        putStrLn $ "First Name: " ++ maybe "N/A" show (rurFirstName userInfo)
        putStrLn $ "Username: " ++ maybe "N/A" show (rurUsername userInfo)
        putStrLn $ "Premium: " ++ show (rurPremium userInfo)
        putStrLn $ "Bot: " ++ show (rurBot userInfo)
    
    putStrLn "\nExample completed!"