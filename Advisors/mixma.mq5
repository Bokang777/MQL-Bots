//+------------------------------------------------------------------+
//|                                                        mixma.mq5 |
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
#include <Expert\Signal\SignalBullsPower.mqh>
#include <Expert\Signal\SignalAMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalBearsPower.mqh>
#include <Expert\Signal\SignalCCI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 ="mixma";     // Document name
ulong                    Expert_MagicNumber           =4981;        //
bool                     Expert_EveryTick             =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen         =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            =0.0;         // Price level to execute a deal
input double             Signal_StopLevel             =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel             =50.0;        // Take Profit level (in points)
input int                Signal_Expiration            =4;           // Expiration of pending orders (in bars)
input int                Signal_BullsPower_PeriodBulls=13;          // Bulls Power(13) Period of calculation
input double             Signal_BullsPower_Weight     =1.0;         // Bulls Power(13) Weight [0...1.0]
input int                Signal_AMA_PeriodMA          =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                Signal_AMA_PeriodFast        =2;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                Signal_AMA_PeriodSlow        =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                Signal_AMA_Shift             =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Signal_AMA_Applied           =PRICE_CLOSE; // Adaptive Moving Average(10,...) Prices series
input double             Signal_AMA_Weight            =1.0;         // Adaptive Moving Average(10,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast       =12;          // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow       =24;          // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal     =9;           // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied          =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight           =1.0;         // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
input int                Signal_TEMA_PeriodMA         =12;          // Triple Exponential Moving Average Period of averaging
input int                Signal_TEMA_Shift            =0;           // Triple Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_TEMA_Applied          =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight           =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
input double             Signal_AC_Weight             =1.0;         // Accelerator Oscillator Weight [0...1.0]
input int                Signal_BearsPower_PeriodBears=13;          // Bears Power(13) Period of calculation
input double             Signal_BearsPower_Weight     =1.0;         // Bears Power(13) Weight [0...1.0]
input int                Signal_CCI_PeriodCCI         =8;           // Commodity Channel Index(8,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_CCI_Applied           =PRICE_CLOSE; // Commodity Channel Index(8,...) Prices series
input double             Signal_CCI_Weight            =1.0;         // Commodity Channel Index(8,...) Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step   =0.02;        // Speed increment
input double             Trailing_ParabolicSAR_Maximum=0.2;         // Maximum rate
//--- inputs for money
input double             Money_FixLot_Percent         =10.0;        // Percent
input double             Money_FixLot_Lots            =0.1;         // Fixed volume
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
//--- Creating filter CSignalBullsPower
   CSignalBullsPower *filter0=new CSignalBullsPower;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodBulls(Signal_BullsPower_PeriodBulls);
   filter0.Weight(Signal_BullsPower_Weight);
//--- Creating filter CSignalAMA
   CSignalAMA *filter1=new CSignalAMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_AMA_PeriodMA);
   filter1.PeriodFast(Signal_AMA_PeriodFast);
   filter1.PeriodSlow(Signal_AMA_PeriodSlow);
   filter1.Shift(Signal_AMA_Shift);
   filter1.Applied(Signal_AMA_Applied);
   filter1.Weight(Signal_AMA_Weight);
//--- Creating filter CSignalMACD
   CSignalMACD *filter2=new CSignalMACD;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodFast(Signal_MACD_PeriodFast);
   filter2.PeriodSlow(Signal_MACD_PeriodSlow);
   filter2.PeriodSignal(Signal_MACD_PeriodSignal);
   filter2.Applied(Signal_MACD_Applied);
   filter2.Weight(Signal_MACD_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter3=new CSignalTEMA;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodMA(Signal_TEMA_PeriodMA);
   filter3.Shift(Signal_TEMA_Shift);
   filter3.Applied(Signal_TEMA_Applied);
   filter3.Weight(Signal_TEMA_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter4=new CSignalAC;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.Weight(Signal_AC_Weight);
//--- Creating filter CSignalBearsPower
   CSignalBearsPower *filter5=new CSignalBearsPower;
   if(filter5==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter5");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter5);
//--- Set filter parameters
   filter5.PeriodBears(Signal_BearsPower_PeriodBears);
   filter5.Weight(Signal_BearsPower_Weight);
//--- Creating filter CSignalCCI
   CSignalCCI *filter6=new CSignalCCI;
   if(filter6==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter6");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter6);
//--- Set filter parameters
   filter6.PeriodCCI(Signal_CCI_PeriodCCI);
   filter6.Applied(Signal_CCI_Applied);
   filter6.Weight(Signal_CCI_Weight);
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
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
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
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
