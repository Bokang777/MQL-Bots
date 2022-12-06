#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
CTrade trade;
CTrailingFixedPips trailing;
input int level1 = 87;
input int level2 = 76;
input int level3 = 50;
input int level4 = 57;
input double stopLoss = 50;
input double takeProfit = 50;
input double multiplier = 4;
input double vol = 1;

int OnInit(void)
  {
   TesterHideIndicators(false);
   
   return(INIT_SUCCEEDED);
  }

//Create an array for the prices
MqlRates PriceInfo[];

//String for the signal
string signal = "";


void OnTick()
  {
  
  //if (ACCOUNT_PROFIT>=ACCOUNT_BALANCE+ACCOUNT_BALANCE*0.1)
    //TesterWithdrawal(500);
  double KArray[];
  double DArray[];
  
  ArraySetAsSeries(KArray, true);
  ArraySetAsSeries(DArray, true);
  
  int stok = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
  double avg5 = iMA(NULL, PERIOD_CURRENT, 20,0,MODE_EMA, PRICE_CLOSE);
  double avg15 = iMA(NULL,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
  double avg60 = iMA(NULL,PERIOD_CURRENT,60,0,MODE_EMA,PRICE_CLOSE);
  
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
  if((KValue1 <level1 ) && (DValue1 < level2 ))
    return;
  if((KValue0 <level3 ) && (DValue0 < level4 ))
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
   
  uint TotalNumberOfDeals = HistoryDealsTotal();
  ulong TicketNumber = 0;
  double OrderProfits = 0;
  int checker = 0;
  HistorySelect(0,TimeCurrent());
  if (signal=="sell")
  {
      SendNotification("I'm Trading Bitch");
      
   
   
         OrderProfits =AccountInfoDouble(ACCOUNT_EQUITY);
         double balance = AccountInfoDouble(ACCOUNT_BALANCE);
         if(PositionsTotal()<=multiplier){
            
              // trade.Sell(vol,NULL,Bid,Bid+stopLoss*_Point,Bid-takeProfit*_Point,NULL);
              trade.Sell(vol,NULL,Bid,NULL,NULL,NULL);
              trade.Sell(vol,NULL,Bid,NULL,NULL,NULL);
              trade.Sell(vol,NULL,Bid,NULL,NULL,NULL);
              return;
               
          }
          if(OrderProfits > balance){
              int i=PositionsTotal()-1;
              while (i>=0)
               {
                  if (trade.PositionClose(PositionGetSymbol(i))) i--;
               }
              
             }
  }
 
  if (signal=="buy")
  {
      
   
         OrderProfits =AccountInfoDouble(ACCOUNT_EQUITY);
         double balance = AccountInfoDouble(ACCOUNT_BALANCE);
         if(PositionsTotal()<multiplier){
            //trade.Buy(vol,NULL,Ask,Ask-stopLoss*_Point,Ask+takeProfit*_Point,NULL);
            trade.Buy(vol,NULL,Ask,NULL,NULL,NULL);
            trade.Buy(vol,NULL,Ask,NULL,NULL,NULL);
            trade.Buy(vol,NULL,Ask,NULL,NULL,NULL);
            return;
         }
         if(OrderProfits > balance){
              int i=PositionsTotal()-1;
              while (i>=0)
               {
                  if (trade.PositionClose(PositionGetSymbol(i))) i--;
               }
              
             }
  
       
      
  }
  
  //Create a chart output
  Comment("Bid: ",Bid,"\n","NextSellPrice: ",NextSellPrice);
  
  
  }
string CheckEntrySignal()
   {
   //buy when candle is bullish
   if (PriceInfo[0].close > PriceInfo[1].open)
   signal = "buy";
   
   //sell when candle is bearish
   if (PriceInfo[0].close < PriceInfo[1].open)
   signal = "sell";
   
   //return signal
   return signal;
   } 

   