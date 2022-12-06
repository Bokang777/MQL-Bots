//+------------------------------------------------------------------+
//|                                                        first.mq5 |
//|                                                Bokang Ntshihlele |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Bokang Ntshihlele"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalStoch.mqh>
#include <Expert\Signal\SignalSAR.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneySizeOptimized.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                      ="first";     // Document name
ulong                    Expert_MagicNumber                =8365;        //
bool                     Expert_EveryTick                  =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen              =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose             =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel                 =0.0;         // Price level to execute a deal
input double             Signal_StopLevel                  =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel                  =50.0;        // Take Profit level (in points)
input int                Signal_Expiration                 =4;           // Expiration of pending orders (in bars)
input int                Signal_0_MA_PeriodMA              =5;           // Moving Average(5,0,MODE_EMA,...) Period of averaging
input int                Signal_0_MA_Shift                 =0;           // Moving Average(5,0,MODE_EMA,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method                =MODE_EMA;    // Moving Average(5,0,MODE_EMA,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied               =PRICE_CLOSE; // Moving Average(5,0,MODE_EMA,...) Prices series
input double             Signal_0_MA_Weight                =1.0;         // Moving Average(5,0,MODE_EMA,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA              =15;          // Moving Average(15,0,...) Period of averaging
input int                Signal_1_MA_Shift                 =0;           // Moving Average(15,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method                =MODE_EMA;    // Moving Average(15,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied               =PRICE_CLOSE; // Moving Average(15,0,...) Prices series
input double             Signal_1_MA_Weight                =1.0;         // Moving Average(15,0,...) Weight [0...1.0]
input int                Signal_2_MA_PeriodMA              =60;          // Moving Average(60,0,...) Period of averaging
input int                Signal_2_MA_Shift                 =0;           // Moving Average(60,0,...) Time shift
input ENUM_MA_METHOD     Signal_2_MA_Method                =MODE_EMA;    // Moving Average(60,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_2_MA_Applied               =PRICE_CLOSE; // Moving Average(60,0,...) Prices series
input double             Signal_2_MA_Weight                =1.0;         // Moving Average(60,0,...) Weight [0...1.0]
input int                Signal_Stoch_PeriodK              =5;           // Stochastic(5,3,3,...) K-period
input int                Signal_Stoch_PeriodD              =3;           // Stochastic(5,3,3,...) D-period
input int                Signal_Stoch_PeriodSlow           =3;           // Stochastic(5,3,3,...) Period of slowing
input ENUM_STO_PRICE     Signal_Stoch_Applied              =STO_LOWHIGH; // Stochastic(5,3,3,...) Prices to apply to
input double             Signal_Stoch_Weight               =1.0;         // Stochastic(5,3,3,...) Weight [0...1.0]
input double             Signal_SAR_Step                   =0.02;        // Parabolic SAR(0.02,0.2) Speed increment
input double             Signal_SAR_Maximum                =0.2;         // Parabolic SAR(0.02,0.2) Maximum rate
input double             Signal_SAR_Weight                 =1.0;         // Parabolic SAR(0.02,0.2) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel      =20;          // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel    =50;          // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_SizeOptimized_DecreaseFactor=3.0;         // Decrease factor
input double             Money_SizeOptimized_Percent       =10.0;        // Percent
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
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_0_MA_PeriodMA);
   filter0.Shift(Signal_0_MA_Shift);
   filter0.Method(Signal_0_MA_Method);
   filter0.Applied(Signal_0_MA_Applied);
   filter0.Weight(Signal_0_MA_Weight);
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
   filter1.PeriodMA(Signal_1_MA_PeriodMA);
   filter1.Shift(Signal_1_MA_Shift);
   filter1.Method(Signal_1_MA_Method);
   filter1.Applied(Signal_1_MA_Applied);
   filter1.Weight(Signal_1_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter2=new CSignalMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_2_MA_PeriodMA);
   filter2.Shift(Signal_2_MA_Shift);
   filter2.Method(Signal_2_MA_Method);
   filter2.Applied(Signal_2_MA_Applied);
   filter2.Weight(Signal_2_MA_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter3=new CSignalStoch;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodK(Signal_Stoch_PeriodK);
   filter3.PeriodD(Signal_Stoch_PeriodD);
   filter3.PeriodSlow(Signal_Stoch_PeriodSlow);
   filter3.Applied(Signal_Stoch_Applied);
   filter3.Weight(Signal_Stoch_Weight);
//--- Creating filter CSignalSAR
   CSignalSAR *filter4=new CSignalSAR;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.Step(Signal_SAR_Step);
   filter4.Maximum(Signal_SAR_Maximum);
   filter4.Weight(Signal_SAR_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
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
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
//--- Creation of money object
   CMoneySizeOptimized *money=new CMoneySizeOptimized;
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
   money.DecreaseFactor(Money_SizeOptimized_DecreaseFactor);
   money.Percent(Money_SizeOptimized_Percent);
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
