#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
CTrade trade;
CTrailingFixedPips trailing;

//Create an array for the prices
MqlRates PriceInfo[];

//String for the signal
string signal = "";


void OnTick()
  {
  double avg5 = iMA(NULL, PERIOD_CURRENT, 20,0,MODE_EMA, PRICE_CLOSE);
  double avg15 = iMA(NULL,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
  // static next sell price
  static double NextSellPrice;
  
  //Get the Bid price
  double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits);
  double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);

  
  //Sort the price array from the current candle downwards
  ArraySetAsSeries(PriceInfo,true);
  
  //Fill the array with the price data
  int PriceData = CopyRates(_Symbol,PERIOD_CURRENT,0,3,PriceInfo);
  
  
  
  //if we have no open positions
  if (PositionsTotal()==0)
  NextSellPrice=0;
  
  
  //CheckEntrySignal
  signal = CheckEntrySignal();
  
  //if the Bid price is <+ NextSellPrice
  //or if NextSellPrice==0
  if ((Ask>=NextSellPrice)||(NextSellPrice==0))
  if ((avg5<avg15))
    return;
  //if we have a sell signal
  if(PositionsTotal()==1)
   return;
  if (signal=="buy")
  {
      
      //open sell position
      trade.Buy(0.50,NULL,Ask,Ask-70*_Point,Ask+100*_Point,NULL);
      //set next sell price level
      NextSellPrice=Ask+100*_Point;
  }
  if (signal=="sell")
  {
      
      //open sell position
      //trade.Buy(0.50,NULL,Ask,Ask-50*_Point,Ask+150*_Point,NULL);
      //set next sell price level
      //NextSellPrice=Ask+50*_Point;
  }
  
  //Create a chart output
  Comment("Bid: ",Bid,"\n","NextSellPrice: ",NextSellPrice);
  
  }
string CheckEntrySignal()
   {
   //buy when candle is bullish
   if (PriceInfo[0].close > PriceInfo[2].open)
   signal = "buy";
   
   //sell when candle is bearish
   if (PriceInfo[0].close < PriceInfo[2].open)
   signal = "sell";
   
   //return signal
   return signal;
   } 

   
      
      

  















