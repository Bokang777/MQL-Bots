//+------------------------------------------------------------------+
//|                                                        scalp.mq5 |
//|                                                Bokang Ntshihlele |
//|                                                       ////////// |
//+------------------------------------------------------------------+
#property copyright "Bokang Ntshihlele"
#property link      "//////////"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
CTrade trade;
CTrailingFixedPips trailing;

input double vol = 1;
input int period1 = 1;
input int period2 = 5;
input int period3 = 10;
input double profitx = 1.3;
input double loss = 0.9;
input int positionsOpen = 4;

void OnTick()
  {
   double avg5 = iMA(NULL, PERIOD_CURRENT, period1,0,MODE_EMA, PRICE_CLOSE);
   double avg15 = iMA(NULL,PERIOD_CURRENT,period2,0,MODE_EMA,PRICE_CLOSE);
   double avg60 = iMA(NULL,PERIOD_CURRENT,period3,0,MODE_EMA,PRICE_CLOSE);
   
   //Get the Bid price
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits);
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   double OrderProfits =AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
  
    if (avg5>avg15 && PositionsTotal()<=positionsOpen){
      
     trade.Buy(vol,NULL,Ask,NULL,NULL,NULL);
     //Sleep(20000);
     //trade.Sell(vol,NULL,Ask,NULL,NULL,NULL);
     
            
    }
    if (avg5<avg15 && PositionsTotal()<=positionsOpen){
      
     //trade.Sell(vol,NULL,Ask,NULL,NULL,NULL);
     trade.Buy(vol,NULL,Ask,NULL,NULL,NULL);
            
    }
   if(OrderProfits > balance+profitx){
     int i=PositionsTotal()-1;
     while (i>=0)
     {
        if (trade.PositionClose(PositionGetSymbol(i))) i--;
           }
              
       }
       
   if(OrderProfits < balance -loss){
     int i=PositionsTotal()-1;
     while (i>=0)
     {
        if (trade.PositionClose(PositionGetSymbol(i))) i--;
           }
              
       }
   
  }
//+------------------------------------------------------------------+
