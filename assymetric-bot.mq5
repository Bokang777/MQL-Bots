#include <Trade\Trade.mqh>
CTrade trade;
input double tprofit = 300;
input double sloss = 300;
input double vol = 0.5;
input float period1 = 5.0;
input float period2 = 15.0;
input float period3 = 60.0;
input int volMultiplier = 2;
void OnTick()
  {
//---

   double avg5 = iMA(_Symbol, PERIOD_CURRENT, period1,1,MODE_EMA, PRICE_CLOSE);
   double avg15 = iMA(_Symbol,PERIOD_CURRENT,period2,1,MODE_EMA,PRICE_CLOSE);
   double avg60 = iMA(_Symbol,PERIOD_CURRENT,period3,1,MODE_EMA,PRICE_CLOSE);
   double current = iClose(_Symbol,PERIOD_CURRENT,0);
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits);
   uint TotalNumberOfDeals = HistoryDealsTotal();
   ulong TicketNumber = 0;
   double OrderProfit = 0;
   HistorySelect(0,TimeCurrent());
   for(uint i=0;i< TotalNumberOfDeals; i++)
   {
      if((TicketNumber=HistoryDealGetTicket(i))>0)
      {
         OrderProfit =HistoryDealGetDouble(TicketNumber, DEAL_PROFIT);
         if(OrderProfit > 0){
            if ((avg5 > avg15) && (avg15 > avg60)){
               if(PositionsTotal()==0){
                  trade.Buy(vol*2.5,NULL,Ask,Ask-300*_Point,Ask+300*_Point,NULL);
               }
             }
               
            if ((avg5 < avg15) && (avg15 < avg60)){
               if(PositionsTotal()==0){
                  //Sell
                  trade.Sell(vol*2.5,NULL,Bid,Bid+300*_Point,Bid-300*_Point,NULL);
               }
            }
         }else
            {
             if ((avg5 > avg15) && (avg15 > avg60)&&PositionsTotal()==0){
                  trade.Buy(vol, NULL,Ask,Ask-300*_Point,Ask+300*_Point,NULL);
               }
           
               
             if ((avg5 < avg15) && (avg15 < avg60)&&PositionsTotal()==0){
                  //Sell
                  trade.Sell(vol, NULL, Bid,Bid+300*_Point,Bid-300*_Point,NULL);
               }
            }
         }
      }
  
   
   
   
  }
//+------------------------------------------------------------------+
