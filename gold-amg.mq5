//+------------------------------------------------------------------+
//|                                                     gold-amg.mq5 |
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
#include <Expert\Signal\SignalTRIX.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalVol.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title           ="gold-amg";  // Document name
ulong                    Expert_MagicNumber     =27578;       //
bool                     Expert_EveryTick       =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen   =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose  =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel      =0.0;         // Price level to execute a deal
input double             Signal_StopLevel       =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel       =50.0;        // Take Profit level (in points)
input int                Signal_Expiration      =4;           // Expiration of pending orders (in bars)
input int                Signal_TriX_PeriodTriX =14;          // Triple Exponential Average Period of calculation
input ENUM_APPLIED_PRICE Signal_TriX_Applied    =PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight     =1.0;         // Triple Exponential Average Weight [0...1.0]
input int                Signal_TEMA_PeriodMA   =12;          // Triple Exponential Moving Average Period of averaging
input int                Signal_TEMA_Shift      =0;           // Triple Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_TEMA_Applied    =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight     =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
input int                Signal_Vols_PeriodBears=13;          // Volumes(13) Period of calculation
input double             Signal_Vols_Weight     =1.0;         // Volumes(13) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent   =10.0;        // Percent
input double             Money_FixLot_Lots      =0.5;         // Fixed volume
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
//--- Creating filter CSignalTriX
   CSignalTriX *filter0=new CSignalTriX;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodTriX(Signal_TriX_PeriodTriX);
   filter0.Applied(Signal_TriX_Applied);
   filter0.Weight(Signal_TriX_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter1=new CSignalTEMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_TEMA_PeriodMA);
   filter1.Shift(Signal_TEMA_Shift);
   filter1.Applied(Signal_TEMA_Applied);
   filter1.Weight(Signal_TEMA_Weight);
//--- Creating filter CSignalBearsPower
   CSignalBearsPower *filter2=new CSignalBearsPower;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodBears(Signal_Vols_PeriodBears);
   filter2.Weight(Signal_Vols_Weight);
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
