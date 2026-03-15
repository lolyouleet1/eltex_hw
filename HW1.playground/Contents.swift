var balance: Double = 10000; // начальный баланс бота
var pricesOfBuy = [Double](); // массив с купленными акциями до закрытия сделки (продажи)
var tradeResult: Double = 0; // результат закрытой сделки
var sumOfTradeResults: Double = 0; // сумма всех закрытых сделок бота

// функция нахождения среднего арифметического в массиве
func calcAverage (array: [Double]) -> Double? {
    
    guard !array.isEmpty else {
        return nil;
    }
    
    var sum: Double = 0
    for i in array {
        sum += i;
    }
    return sum / Double(array.count);
}

// бот занимается скальпингом на акциях газпрома
// Начальный баланс - 10000 рублей (2 месяца откладывал с обедов).
// Цена - случайное вещественное число в диапазоне от 100 до 200 рублей
// Количество сделок - 1000.
for _ in 0...999 {
    let currentPrice: Double = Double.random(in: 100...200); // текущая цена акции
    let numberOfSellOrders: Int = Int.random(in: 0...10000); // количество заявок на продажу в биржевом стакане
    let numberOfBuyOrders: Int = Int.random(in: 0...10000); // количество заявок на покупку в биржевом стакане
    let spreadBetweenOrders: Int = numberOfSellOrders - numberOfBuyOrders; // разница в количестве заявок
    let wantToSell: Bool = numberOfSellOrders > numberOfBuyOrders; // условие для продажи акций: кол-во заявок на продажу > больше кол-ва заявок на покупку
        
    /*
     блок срабатывает, если нет акций и бот хочет их продать
     или если баланс меньше текущей стоимости акции и бот хочет ее купить
    */
    guard !(pricesOfBuy.isEmpty && wantToSell) && !(balance < currentPrice && !wantToSell) else {
        print("\(currentPrice) рублей - игнорирование");
        print("---");
        continue;
    }
    
    /*
     Логика работы бота:
     При спреде в заявках 0 < spread < 400 пропускаем итерацию, бот ничего не делает.
     При спреде в заявках spread >= 400 продаем все имеющиеся на руках акции по текущей цене.
     Во всех остальных случаях бот покупает акцию.
     */
    
    // игнорирование
    if wantToSell && spreadBetweenOrders < 400 {
        print("\(currentPrice) рублей - игнорирование");
        continue;
    }
    
    // покупка
    else if wantToSell && spreadBetweenOrders >= 400 {
        guard let avgPrice = calcAverage(array: pricesOfBuy) else {
            continue;
        }
        
        var stocksAmount: Int = pricesOfBuy.count;
        tradeResult = currentPrice * Double(stocksAmount) - avgPrice * Double(stocksAmount);
        sumOfTradeResults += tradeResult;
        balance += currentPrice * Double(stocksAmount);
        
        print("\(currentPrice) рублей - продажа (\(stocksAmount) акций на счету)");
        print("Продажа FROM = \(avgPrice) -> TO = \(currentPrice), INCOME = \(tradeResult)");
        
        pricesOfBuy.removeAll();
    }
    
    // продажа (все остальные случаи)
    else {
        pricesOfBuy.append(currentPrice);
        balance -= currentPrice;
        
        print("\(currentPrice) рублей - покупка");
    }
    
    print("---");
}

// продажа акций по текущей цене, если они остались на руках после завершения цикла
let currentPrice: Double = Double.random(in: 100...200); // текущая цена акции
if !pricesOfBuy.isEmpty {
    let avgPrice: Double? = calcAverage(array: pricesOfBuy);
    
    var stocksAmount: Int = pricesOfBuy.count;
    // смело распаковываю optional, т.к. в условии уже стоит "!pricesOfBuy.isEmpty"
    tradeResult = currentPrice * Double(stocksAmount) - avgPrice! * Double(stocksAmount);
    sumOfTradeResults += tradeResult;
    balance += currentPrice * Double(stocksAmount);
    
    print("\(currentPrice) рублей - продажа (\(stocksAmount) акций на счету)");
    print("Продажа FROM = \(avgPrice!) -> TO = \(currentPrice), INCOME = \(tradeResult)");
    
    pricesOfBuy.removeAll();
    
    print("---");
}

print("Итоговый баланс: \(balance.rounded())");
print("Результат сделок бота: \(sumOfTradeResults.rounded())");
