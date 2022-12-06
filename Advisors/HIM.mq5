//+------------------------------------------------------------------+
//|                                                          HIM.mq5 |
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
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title         ="HIM"; // Document name
ulong        Expert_MagicNumber   =22206; //
bool         Expert_EveryTick     =false; //
//--- inputs for main signal
input int    Signal_ThresholdOpen =10;    // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose=10;    // Signal threshold value to close [0...100]
input double Signal_PriceLevel    =0.0;   // Price level to execute a deal
input double Signal_StopLevel     =50.0;  // Stop Loss level (in points)
input double Signal_TakeLevel     =50.0;  // Take Profit level (in points)
input int    Signal_Expiration    =4;     // Expiration of pending orders (in bars)
input double Signal_1_AC_Weight   =1.0;   // Accelerator Oscillator M2 Weight [0...1.0]
input double Signal_2_AC_Weight   =1.0;   // Accelerator Oscillator M3 Weight [0...1.0]
input double Signal_3_AC_Weight   =1.0;   // Accelerator Oscillator M4 Weight [0...1.0]
input double Signal_4_AC_Weight   =1.0;   // Accelerator Oscillator M6 Weight [0...1.0]
input double Signal_5_AC_Weight   =1.0;   // Accelerator Oscillator M10 Weight [0...1.0]
input double Signal_6_AC_Weight   =1.0;   // Accelerator Oscillator M12 Weight [0...1.0]
input double Signal_7_AC_Weight   =1.0;   // Accelerator Oscillator M15 Weight [0...1.0]
input double Signal_8_AC_Weight   =1.0;   // Accelerator Oscillator M20 Weight [0...1.0]
input double Signal_9_AC_Weight   =1.0;   // Accelerator Oscillator M30 Weight [0...1.0]
input double Signal_10_AC_Weight  =1.0;   // Accelerator Oscillator H1 Weight [0...1.0]
input double Signal_11_AC_Weight  =1.0;   // Accelerator Oscillator H2 Weight [0...1.0]
input double Signal_12_AC_Weight  =1.0;   // Accelerator Oscillator H3 Weight [0...1.0]
input double Signal_13_AC_Weight  =1.0;   // Accelerator Oscillator H4 Weight [0...1.0]
//--- inputs for money
input double Money_FixLot_Percent =10.0;  // Percent
input double Money_FixLot_Lots    =0.1;   // Fixed volume
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
   filter0.Period(PERIOD_M1);
//--- Creating filter CSignalAC
   CSignalAC *filter1=new CSignalAC;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Period(PERIOD_M2);
   filter1.Weight(Signal_1_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter2=new CSignalAC;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.Period(PERIOD_M3);
   filter2.Weight(Signal_2_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter3=new CSignalAC;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.Period(PERIOD_M4);
   filter3.Weight(Signal_3_AC_Weight);
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
   filter4.Period(PERIOD_M6);
   filter4.Weight(Signal_4_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter5=new CSignalAC;
   if(filter5==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter5");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter5);
//--- Set filter parameters
   filter5.Period(PERIOD_M10);
   filter5.Weight(Signal_5_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter6=new CSignalAC;
   if(filter6==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter6");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter6);
//--- Set filter parameters
   filter6.Period(PERIOD_M12);
   filter6.Weight(Signal_6_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter7=new CSignalAC;
   if(filter7==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter7");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter7);
//--- Set filter parameters
   filter7.Period(PERIOD_M15);
   filter7.Weight(Signal_7_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter8=new CSignalAC;
   if(filter8==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter8");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter8);
//--- Set filter parameters
   filter8.Period(PERIOD_M20);
   filter8.Weight(Signal_8_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter9=new CSignalAC;
   if(filter9==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter9");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter9);
//--- Set filter parameters
   filter9.Period(PERIOD_M30);
   filter9.Weight(Signal_9_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter10=new CSignalAC;
   if(filter10==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter10");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter10);
//--- Set filter parameters
   filter10.Period(PERIOD_H1);
   filter10.Weight(Signal_10_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter11=new CSignalAC;
   if(filter11==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter11");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter11);
//--- Set filter parameters
   filter11.Period(PERIOD_H2);
   filter11.Weight(Signal_11_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter12=new CSignalAC;
   if(filter12==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter12");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter12);
//--- Set filter parameters
   filter12.Period(PERIOD_H3);
   filter12.Weight(Signal_12_AC_Weight);
//--- Creating filter CSignalAC
   CSignalAC *filter13=new CSignalAC;
   if(filter13==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter13");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter13);
//--- Set filter parameters
   filter13.Period(PERIOD_H4);
   filter13.Weight(Signal_13_AC_Weight);
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
