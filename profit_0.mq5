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
  double KArray[];
  double DArray[];
  
  ArraySetAsSeries(KArray, true);
  ArraySetAsSeries(DArray, true);
  
  int stok = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
  double avg5 = iMA(NULL, PERIOD_CURRENT, 3.1415926535897,0,MODE_EMA, PRICE_CLOSE);
  double avg15 = iMA(NULL,PERIOD_CURRENT,3.1415926535897*3.1415926535897,0,MODE_EMA,PRICE_CLOSE);
  
  CopyBuffer(stok,0,0,3,KArray);
  CopyBuffer(stok,1,0,3,DArray);
  
  double KValue0 = KArray[0];
  double DValue0 = DArray[0];
  double KValue1 = KArray[1];
  double DValue1 = DArray[1];
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
  if((KValue1 <75 ) && (DValue1 < 80 ))
    return;
  if((KValue0 <75 ) && (DValue0 < 80 ))
    return;
  
  
  
  //CheckEntrySignal
  signal = CheckEntrySignal();
  
  //if the Bid price is <+ NextSellPrice
  //or if NextSellPrice==0
  if ((Bid<=NextSellPrice)||(NextSellPrice==0))
  if ((avg5>avg15))
  return;
  //if we have a sell signal
  if(PositionsTotal()==1)
   return;
  if (signal=="sell")
  {
      
      //open sell position
      //trade.Sell(0.50,NULL,Bid,Bid+100*_Point,Bid-115*_Point,NULL);
      trade.Buy(0.50,NULL,Ask,Ask-120*_Point,Ask+120*_Point,NULL);
      //set next sell price level
      NextSellPrice=Bid+50*_Point;
  }
  if((KValue1 >25 ) && (DValue1 > 20 ))
  
    return;
  if((KValue0 >25 ) && (DValue0 > 20 ))
  
    return;
  if ((avg5<avg15))
    return;
  if (signal=="buy")
  {
      
      //open sell position
      trade.Sell(0.50,NULL,Bid,Bid+120*_Point,Bid-120*_Point,NULL);
      //trade.Buy(0.50,NULL,Ask,Ask-100*_Point,Ask+115*_Point,NULL);
      //set next sell price level
      NextSellPrice=Ask-50*_Point;
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

   
      
      

  















