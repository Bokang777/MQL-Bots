//+------------------------------------------------------------------+
//|                                                        vol-D.mq5 |
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
#include <Expert\Signal\SignalITF.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalVol.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title            ="vol-D";     // Document name
ulong                    Expert_MagicNumber      =22343;       //
bool                     Expert_EveryTick        =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen    =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose   =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel       =0.0;         // Price level to execute a deal
input double             Signal_StopLevel        =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;        // Take Profit level (in points)
input int                Signal_Expiration       =4;           // Expiration of pending orders (in bars)
input int                Signal_ITF_GoodHourOfDay=-1;          // IntradayTimeFilter(-1,0,-1,...) Good hour
input int                Signal_ITF_BadHoursOfDay=0;           // IntradayTimeFilter(-1,0,-1,...) Bad hours (bit-map)
input int                Signal_ITF_GoodDayOfWeek=-1;          // IntradayTimeFilter(-1,0,-1,...) Good day of week
input int                Signal_ITF_BadDaysOfWeek=0;           // IntradayTimeFilter(-1,0,-1,...) Bad days of week (bit-map)
input double             Signal_ITF_Weight       =1.0;         // IntradayTimeFilter(-1,0,-1,...) Weight [0...1.0]
input int                Signal_MA_PeriodMA      =12;          // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift         =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method        =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied       =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight        =1.0;         // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_Vols_PeriodBears =13;          // Volumes(13) Period of calculation
input double             Signal_Vols_Weight      =1.0;         // Volumes(13) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent    =10.0;        // Percent
input double             Money_FixLot_Lots       =0.2;         // Fixed volume
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
//--- Creating filter CSignalITF
   CSignalITF *filter0=new CSignalITF;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.GoodHourOfDay(Signal_ITF_GoodHourOfDay);
   filter0.BadHoursOfDay(Signal_ITF_BadHoursOfDay);
   filter0.GoodDayOfWeek(Signal_ITF_GoodDayOfWeek);
   filter0.BadDaysOfWeek(Signal_ITF_BadDaysOfWeek);
   filter0.Weight(Signal_ITF_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_MA_PeriodMA);
   filter1.Shift(Signal_MA_Shift);
   filter1.Method(Signal_MA_Method);
   filter1.Applied(Signal_MA_Applied);
   filter1.Weight(Signal_MA_Weight);
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
