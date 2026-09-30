# Meal Planner - iOS
Swift UI mvi project :
use themealdb api

## 推广文本与描述

### 推广文本

日日都諗唔到食咩？Meal Planner 幫你將煮食靈感變成下一餐。你可以喺 TheMealDB 嘅全球食譜入面，探索唔同地區、類別同食材嘅菜式，快速搜尋想食嘅料理，亦可以用隨機推薦搵到新嘅晚餐靈感。見到鍾意嘅食譜，一按收藏，之後隨時返去 Favourite 查看同篩選，搵菜、揀菜、儲菜都更加輕鬆。

### 描述

Meal Planner 係一款用 SwiftUI 製作嘅 iOS 食譜探索 App。App 透過 TheMealDB API 取得食譜資料，提供首頁推薦、隨機揀餐、關鍵字搜尋、地區分類、料理類別、食材列表同食譜詳情等功能。用戶可以查看菜式圖片、地區、類別同食材資料，亦可以將鍾意嘅食譜加入收藏。

主要功能：

- 瀏覽推薦食譜、熱門類別同唔同地區料理。
- 按食材、類別或者地區篩選相關食譜。
- 用關鍵字搜尋想食嘅菜式。
- 透過隨機揀餐快速搵到料理靈感。
- 查看食譜詳情，並由詳情頁繼續探索相關食材。
- 收藏鍾意嘅食譜，並喺 Favourite 頁面按地區同類別篩選。
- 喺 Profile 頁面查看本機快取同收藏統計，並管理瀏覽快取、查詢快取同收藏資料。


## Roadmap
- [ ] pretty detail screen
- [x] lottie view
- [ ] favorite screen, separate vm

### Obstacle
- [] have not decide the data structure of fav 
- [] attractive layout of favourite page, middle tab


## Data Source

* The app uses [Recipe API](https://www.themealdb.com/api.php) for fetching the recipes.
* All Ingredients[Here](https://www.themealdb.com/api/json/v1/1/list.php?i=list)
* All Categories[Here](https://www.themealdb.com/api/json/v1/1/list.php?c=list)
* All Areas[Here](https://www.themealdb.com/api/json/v1/1/list.php?a=list)
* Filter by ingredient[Here](https://www.themealdb.com/api/json/v1/1/filter.php?i=chicken_breast)
* Filter by Area[Here](https://www.themealdb.com/api/json/v1/1/filter.php?a=Canadian)
* Filter by Category[Here](https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood)
* Search by Name[Here](https://www.themealdb.com/api/json/v1/1/search.php?s=beef)
* Get Recipe Detail[Here](https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772)
* Ingredient Image
  * www.themealdb.com/images/ingredients/lime.png
  * www.themealdb.com/images/ingredients/lime-small.png
  * www.themealdb.com/images/ingredients/lime-medium.png
  * www.themealdb.com/images/ingredients/lime-large.png
