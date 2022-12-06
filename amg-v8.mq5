//+------------------------------------------------------------------+
//|                                                       amg-v8.mq5 |
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
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalAO.mqh>
#include <Expert\Signal\SignalBearsPower.mqh>
#include <Expert\Signal\SignalBullsPower.mqh>
#include <Expert\Signal\SignalFrAMA.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 ="amg-v8";    // Document name
ulong                    Expert_MagicNumber           =9338;        //
bool                     Expert_EveryTick             =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen         =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            =0.0;         // Price level to execute a deal
input double             Signal_StopLevel             =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel             =50.0;        // Take Profit level (in points)
input int                Signal_Expiration            =4;           // Expiration of pending orders (in bars)
input double             Signal_AC_Weight             =1.0;         // Accelerator Oscillator Weight [0...1.0]
input double             Signal_AO_Weight             =1.0;         // Awesome Oscillator Weight [0...1.0]
input int                Signal_BearsPower_PeriodBears=13;          // Bears Power(13) Period of calculation
input double             Signal_BearsPower_Weight     =1.0;         // Bears Power(13) Weight [0...1.0]
input int                Signal_BullsPower_PeriodBulls=13;          // Bulls Power(13) Period of calculation
input double             Signal_BullsPower_Weight     =1.0;         // Bulls Power(13) Weight [0...1.0]
input int                Signal_FraMA_PeriodMA        =12;          // Fractal Adaptive Moving Average Period of averaging
input int                Signal_FraMA_Shift           =0;           // Fractal Adaptive Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_FraMA_Applied         =PRICE_CLOSE; // Fractal Adaptive Moving Average Prices series
input double             Signal_FraMA_Weight          =1.0;         // Fractal Adaptive Moving Average Weight [0...1.0]
input int                Signal_TEMA_PeriodMA         =12;          // Triple Exponential Moving Average Period of averaging
input int                Signal_TEMA_Shift            =0;           // Triple Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_TEMA_Applied          =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight           =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step   =0.02;        // Speed increment
input double             Trailing_ParabolicSAR_Maximum=0.2;         // Maximum rate
//--- inputs for money
input double             Money_FixLot_Percent         =3.0;         // Percent
input double             Money_FixLot_Lots            =0.5;         // Fixed volume
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
//--- Creating filter CSignalAC
   CSignalAC *filter0=new CSignalAC;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Weight(Signal_AC_Weight);
//--- Creating filter CSignalAO
   CSignalAO *filter1=new CSignalAO;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Weight(Signal_AO_Weight);
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
   filter2.PeriodBears(Signal_BearsPower_PeriodBears);
   filter2.Weight(Signal_BearsPower_Weight);
//--- Creating filter CSignalBullsPower
   CSignalBullsPower *filter3=new CSignalBullsPower;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodBulls(Signal_BullsPower_PeriodBulls);
   filter3.Weight(Signal_BullsPower_Weight);
//--- Creating filter CSignalFrAMA
   CSignalFrAMA *filter4=new CSignalFrAMA;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.PeriodMA(Signal_FraMA_PeriodMA);
   filter4.Shift(Signal_FraMA_Shift);
   filter4.Applied(Signal_FraMA_Applied);
   filter4.Weight(Signal_FraMA_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter5=new CSignalTEMA;
   if(filter5==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter5");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter5);
//--- Set filter parameters
   filter5.PeriodMA(Signal_TEMA_PeriodMA);
   filter5.Shift(Signal_TEMA_Shift);
   filter5.Applied(Signal_TEMA_Applied);
   filter5.Weight(Signal_TEMA_Weight);
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
