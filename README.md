# DateReg API Library

Haskell клиент для работы с [DateRegBot API](https://docs.goy.guru/api) - получение даты регистрации аккаунтов Telegram, ID пользователей по их имени и другие данные.

## Требования

- Python 3.9+

## Установка

Через GitHub

Добавьте в ваш cabal.project:
```cabal
source-repository-package
  type: git
  location: https://github.com/yourusername/date-reg-api-hs
  tag: v1.0.0
```

Или укажите зависимость в .cabal файле:
```cabal
build-depends: date-reg-api >= 1.0.0
```
Локальная установка
```bash
git clone https://github.com/yourusername/date-reg-api-hs
cd date-reg-api-hs
cabal install
```

## Быстрый старт

```haskell
{-# LANGUAGE OverloadedStrings #-}

import DateRegAPI
import Data.Default

main :: IO ()
main = do
  let config = def
        { configToken = "your-api-token-here"
        }
  
  withDateRegAPI config $ \api -> do
    -- Получаем дату регистрации по ID пользователя
    result <- runExceptT $ runReaderT (runDateRegM (getCreationDateSmart 123456789)) api
    case result of
      Left err -> putStrLn $ "Error: " ++ show err
      Right response -> do
        putStrLn $ "User ID: " ++ show (cdrUserId response)
        putStrLn $ "Creation Date: " ++ show (cdrCreationDate response)
        putStrLn $ "Accuracy: " ++ show (cdrAccuracyPercent response) ++ "%"
```

## Методы API

### `getCreationDateFast :: Int -> DateRegM CreationDateResponse`

Определяет приблизительную дату регистрации пользователя Telegram с точностью до месяца. Это самый быстрый, но наименее точный метод.

Параметры:

    Int - ID пользователя Telegram

Возвращает:
```haskell
CreationDateResponse
  { cdrUserId = 6362784873
  , cdrCreationDate = "1.2024"
  , cdrAccuracyText = "точная запись (100%)"
  , cdrAccuracyPercent = 100
  }
```

Пример использования:
```haskell
result <- runExceptT $ runReaderT (runDateRegM (getCreationDateFast 6362784873)) api
case result of
  Left err -> putStrLn $ "Error: " ++ show err
  Right response -> print response
```
**Стоимость:** $0.0005 за запрос

### `getCreationDateSmart :: Int -> DateRegM CreationDateResponse`

Определяет дату регистрации пользователя Telegram с точностью до месяца. Этот метод использует 12 алгоритмов, включая собственную нейросеть.

Параметры:

    Int - ID пользователя Telegram

Возвращает:
```haskell

CreationDateResponse
  { cdrUserId = 7308887716
  , cdrCreationDate = "10.2024"
  , cdrAccuracyText = "высокая (87%)"
  , cdrAccuracyPercent = 87
  }
```
Пример использования:
```haskell

result <- runExceptT $ runReaderT (runDateRegM (getCreationDateSmart 7308887716)) api
case result of
  Left err -> putStrLn $ "Error: " ++ show err
  Right response -> print response
```
**Стоимость:** $0.001 за запрос

### `getCreationDateByUsername :: Text -> DateRegM CreationDateByUsernameResponse`

Определяет дату регистрации пользователя Telegram по его username. Метод сначала преобразует username в ID, а затем применяет алгоритм getCreationDateSmart.

Параметры:

    Text - Имя пользователя Telegram (можно с @ или без)

Возвращает:
```haskell
CreationDateByUsernameResponse
  { cdburUsername = "filimono"
  , cdburUserId = 678158951
  , cdburCreationDate = "12.2018"
  , cdburAccuracyText = "высокая (89%)"
  , cdburAccuracyPercent = 89
  }
```

Пример использования:
```haskell

result <- runExceptT $ runReaderT (runDateRegM (getCreationDateByUsername "filimono")) api
case result of
  Left err -> putStrLn $ "Error: " ++ show err
  Right response -> print response
```

**Стоимость:** $0.003 за запрос

### `resolveUsername :: Text -> DateRegM ResolveUsernameResponse`

Преобразует имя пользователя Telegram (username) в ID пользователя и возвращает полную информацию о пользователе.

Параметры:

    Text - Имя пользователя Telegram (можно с @ или без)

Возвращает:
```haskell

ResolveUsernameResponse
  { rurId = 6362784873
  , rurFirstName = Just "Pavel"
  , rurLastName = Nothing
  , rurUsername = Nothing
  , rurPhone = Nothing
  , rurPremium = True
  , rurVerified = False
  , rurBot = False
  , rurDeleted = False
  , rurScam = False
  , rurFake = False
  , rurAccessHash = Nothing
  , rurPhoto = Nothing
  , rurUsernames = []
  }
```
Пример использования:
```haskell

result <- runExceptT $ runReaderT (runDateRegM (resolveUsername "telegram")) api
case result of
  Left err -> putStrLn $ "Error: " ++ show err
  Right userInfo -> do
    putStrLn $ "User ID: " ++ show (rurId userInfo)
    putStrLn $ "First Name: " ++ maybe "N/A" show (rurFirstName userInfo)
    putStrLn $ "Premium: " ++ show (rurPremium userInfo)
```

## Обработка ошибок

Библиотека использует систему типов для обработки ошибок. Все функции возвращают Either DateRegError a.

Типы ошибок:

    AuthenticationError - ошибка аутентификации (неверный токен)

    PaymentError - недостаточно средств на балансе

    ForbiddenError - доступ запрещен

    NotFoundError - endpoint не найден

    ServerError - внутренняя ошибка сервера

    NetworkError - ошибка сети

    ParseError - ошибка парсинга ответа

    ValidationError - ошибка валидации входных данных

## Получение API-ключа

1. Откройте бота [@dateregbot](https://t.me/dateregbot) в Telegram
2. Отправьте команду `/api` или нажмите на гиперссылку API в главном меню
3. Скопируйте API-ключ

## Тарифы

| Метод | Стоимость за запрос | Стоимость за 1000 запросов |
|-------|---------------------|----------------------------|
| `getCreationDateFast` | $0.0005 | $0.5 |
| `getCreationDateSmart` | $0.001 | $1.0 |
| `getCreationDateByUsername` | $0.003 | $3.0 |
| `resolveUsername` | $0.0025 | $2.5 |

## Лицензия

[MIT](LICENSE)

## Поддержка

Если у вас возникли вопросы или проблемы:

- 📖 [Документация API](https://docs.goy.guru/api)
- 💬 Telegram: [@gitapps](https://t.me/gitapps)
- 🤖 Бот: [@dateregbot](https://t.me/dateregbot)

