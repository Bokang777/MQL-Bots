//+------------------------------------------------------------------+
//|                                                         mff3.mq5 |
//|                                                Bokang Ntshihlele |
//|                                                       ////////// |
//+------------------------------------------------------------------+
#property copyright "Bokang Ntshihlele"
#property link      "//////////"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\ATR.mqh>
#include <Expert\Signal\SignalRVI.mqh>
#include <Expert\Signal\SignalCCI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="mff3";      // Document name
ulong                    Expert_MagicNumber   =31518;       //
bool                     Expert_EveryTick     =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose=10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel    =0.0;         // Price level to execute a deal
input double             Signal_StopLevel     =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel     =50.0;        // Take Profit level (in points)
input int                Signal_Expiration    =4;           // Expiration of pending orders (in bars)
input int                Signal_ATR_PeriodATR =8;           // Average True Range(8,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_ATR_Applied   =PRICE_CLOSE; // Average True Range(8,...) Prices series
input double             Signal_ATR_Weight    =1.0;         // Average True Range(8,...) Weight [0...1.0]
input int                Signal_RVI_PeriodRVI =10;          // Relative Vigor Index(10) Period of calculation
input double             Signal_RVI_Weight    =1.0;         // Relative Vigor Index(10) Weight [0...1.0]
input int                Signal_CCI_PeriodCCI =8;           // Commodity Channel Index(8,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_CCI_Applied   =PRICE_CLOSE; // Commodity Channel Index(8,...) Prices series
input double             Signal_CCI_Weight    =1.0;         // Commodity Channel Index(8,...) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent =10.0;        // Percent
input double             Money_FixLot_Lots    =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalATR
   CSignalATR *filter0=new CSignalATR;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodATR(Signal_ATR_PeriodATR);
   filter0.Applied(Signal_ATR_Applied);
   filter0.Weight(Signal_ATR_Weight);
//--- Creating filter CSignalRVI
   CSignalRVI *filter1=new CSignalRVI;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodRVI(Signal_RVI_PeriodRVI);
   filter1.Weight(Signal_RVI_Weight);
//--- Creating filter CSignalCCI
   CSignalCCI *filter2=new CSignalCCI;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodCCI(Signal_CCI_PeriodCCI);
   filter2.Applied(Signal_CCI_Applied);
   filter2.Weight(Signal_CCI_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
