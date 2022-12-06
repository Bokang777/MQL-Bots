//+------------------------------------------------------------------+
//|                                                         bmw1.mq5 |
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
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalEnvelopes.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title              ="bmw1";      // Document name
ulong                    Expert_MagicNumber        =7825;        //
bool                     Expert_EveryTick          =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen      =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose     =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel         =0.0;         // Price level to execute a deal
input double             Signal_StopLevel          =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel          =50.0;        // Take Profit level (in points)
input int                Signal_Expiration         =4;           // Expiration of pending orders (in bars)
input int                Signal_TriX_PeriodTriX    =14;          // Triple Exponential Average Period of calculation
input ENUM_APPLIED_PRICE Signal_TriX_Applied       =PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight        =1.0;         // Triple Exponential Average Weight [0...1.0]
input int                Signal_MA_PeriodMA        =12;          // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift           =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method          =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied         =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight          =1.0;         // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_Envelopes_PeriodMA =45;          // Envelopes(45,0,MODE_SMA,...) Period of averaging
input int                Signal_Envelopes_Shift    =0;           // Envelopes(45,0,MODE_SMA,...) Time shift
input ENUM_MA_METHOD     Signal_Envelopes_Method   =MODE_SMA;    // Envelopes(45,0,MODE_SMA,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_Envelopes_Applied  =PRICE_CLOSE; // Envelopes(45,0,MODE_SMA,...) Prices series
input double             Signal_Envelopes_Deviation=0.15;        // Envelopes(45,0,MODE_SMA,...) Deviation
input double             Signal_Envelopes_Weight   =1.0;         // Envelopes(45,0,MODE_SMA,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period        =12;          // Period of MA
input int                Trailing_MA_Shift         =0;           // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method        =MODE_SMA;    // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied       =PRICE_CLOSE; // Prices series
//--- inputs for money
input double             Money_FixLot_Percent      =10.0;        // Percent
input double             Money_FixLot_Lots         =0.5;         // Fixed volume
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
//--- Creating filter CSignalEnvelopes
   CSignalEnvelopes *filter2=new CSignalEnvelopes;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_Envelopes_PeriodMA);
   filter2.Shift(Signal_Envelopes_Shift);
   filter2.Method(Signal_Envelopes_Method);
   filter2.Applied(Signal_Envelopes_Applied);
   filter2.Deviation(Signal_Envelopes_Deviation);
   filter2.Weight(Signal_Envelopes_Weight);
//--- Creation of trailing object
   CTrailingMA *trailing=new CTrailingMA;
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
   trailing.Period(Trailing_MA_Period);
   trailing.Shift(Trailing_MA_Shift);
   trailing.Method(Trailing_MA_Method);
   trailing.Applied(Trailing_MA_Applied);
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
