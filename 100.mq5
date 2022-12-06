#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
CTrade trade;
CTrailingFixedPips trailing;

//int                Trailing_FixedPips_StopLevel  =20;          // Stop Loss trailing level (in points)
//int                Trailing_FixedPips_ProfitLevel=50;          // Take Profit trailing level (in points)

void OnTick()
  {

   double KArray[];
   double DArray[];
//   int                Trailing_FixedPips_StopLevel  =20;          // Stop Loss trailing level (in points)
//   int                Trailing_FixedPips_ProfitLevel=50;          // Take Profit trailing level (in points)

   ArraySetAsSeries(KArray, true);
   ArraySetAsSeries(DArray, true);
   
   double par =  iSAR(_Symbol,PERIOD_CURRENT,0.02,0.2);
   double avg5 = iMA(NULL, PERIOD_CURRENT, 5,0,MODE_EMA, PRICE_CLOSE);
   double avg15 = iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_CLOSE);
   double avg60 = iMA(NULL,PERIOD_CURRENT,60,0,MODE_EMA,PRICE_CLOSE);
   double avg200 = iMA(NULL,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_CLOSE);
   int stok = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
   
   CopyBuffer(stok,0,0,3,KArray);
   CopyBuffer(stok,1,0,3,DArray);
   
   double KValue0 = KArray[0];
   double DValue0 = DArray[0];
   double KValue1 = KArray[1];
   double DValue1 = DArray[1];
   
   MqlRates BarData[1];
   CopyRates(Symbol(), Period(),0,1,BarData);
   
   //double current = BarData[0].close;
   double askp = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   double bidp = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   long slevel = SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
  // int sdist =MathMax(slevel +1,50);
 //  double sl = NormalizeDouble(askp -  10* _Point,_Digits);
   //double tp = NormalizeDouble(askp +  10* _Point,_Digits);
   double vol = 0.01;
   double accbal = AccountInfoDouble(ACCOUNT_BALANCE);
   double aq = AccountInfoDouble(ACCOUNT_EQUITY);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   
   
   
   if ((avg5 > avg15))
      //if ((KValue0>DValue0) && (KValue1<DValue1))
   {//Buy
         
      trade.Buy(0.2, NULL, Bid, Bid-50*_Point, Bid+50*_Point, NULL);
           
           //trade.Sell(0.5, _Symbol, askp, askp + 300*_Point, askp -800*_Point, NULL);
           //trailing.StopLevel(20);
          // trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);

         
//   }else if ((avg5 < avg60) && (avg60>=avg15) && (avg5 < avg15)  &&(PositionsTotal()<1) && (KValue1 > 85) && (DValue1 > 85) && (KValue0<DValue0) && (KValue1>DValue1))
      //if ((KValue0<DValue0) && (KValue1>DValue1))
//      {//Sell
         
           //trailing.StopLevel(20.0);
           //trailing.ProfitLevel(50.0);
//         trade.Sell(0.2, NULL, askp, 0, 0, NULL);
           //trade.Buy(0.5, _Symbol, askp, askp -300*_Point, 0, NULL);
         
       }
         
//CheckTrailingStop(askp);
         }
      
//   if ((aq - accbal) >= 3)  
//      {
//      trade.PositionClose(PositionGetSymbol(0));
//      }
      
//   else if ((aq - accbal) <= -1)
//      {
//      trade.PositionClose(PositionGetSymbol(0));
//      }   
//void CheckTrailingStop(double askp){
      
//      double SL = NormalizeDouble(askp-150*_Point,_Digits);
//      double SL2 = NormalizeDouble(askp+150*_Point,_Digits);
      
//      for (int i=PositionsTotal()-1; i>=0; i--){
      
//         string symbol = PositionGetSymbol(i);
//         if (_Symbol==symbol){
            
//            ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
            
//            double CurrentStopLoss=PositionGetDouble(POSITION_SL);
            
            
//            if (CurrentStopLoss<SL)
//            {
//               trade.PositionModify(PositionTicket,(CurrentStopLoss+10*_Point),0);
//            }else if (CurrentStopLoss>SL2)
//            {
//               trade.PositionModify(PositionTicket,(CurrentStopLoss-10*_Point),0);
//            }
 //           }
         
   //      }
      
     // }      
  


  
