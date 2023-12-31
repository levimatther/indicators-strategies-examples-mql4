//+------------------------------------------------------------------+
//|                                   Simple Martingale Template.mq4 |
//|                           Copyright © 2015, Joel Tagle Protusada |
//|                     https://www.facebook.com/groups/FXFledgling/ |
//+------------------------------------------------------------------+
#property copyright  "Copyright © 2015 by Joel Tagle Protusada"
#property link       "https://www.facebook.com/groups/FXFledgling/"
#property version    "1.00"
#property strict


//MoneyForOneLotTypeSetting
enum MoneyForOneLotTypeSetting {
   Balance     = 1,                                   //Balance
   Equity      = 2,                                   //Equity
   FreeMargin  = 3                                    //FreeMargin
};

// setting value
input string   Receipt                                = "Enter Your Receipt Here";  
input string   Email                                  = "Enter Your Email Here";  
input bool     Use_Amplitude                          = true;
input int      Amplitude                              = 2;
input int      Amplitude1                             = 10;
input int      FixTP                                  = 650;
input int      RSIPer                                 = 9;
input ENUM_APPLIED_PRICE RSI_Price                    = PRICE_CLOSE;             //RSI_Price
input bool     Use_Breakeven_Level                    = true;
input int      Breakeven_Level                        = 20;
input double   Breakeven_Point                        = 1.0;
input string   LT001                                  = "======MONEYMANAGEMENT MODULE======";
input int      LotVariant                             = 3;
double   FixLot                                 = 0.01;
input int      MoneyForOneLot                         = 300;
input MoneyForOneLotTypeSetting MoneyForOneLot_Type   = Balance;                 //MoneyForOneLot_Type
input int      lotdecimal                             = 2;
input string   Lots015                                = "==================";
input double   LotExponent                            = 2.5;
input bool     DynamicPips                            = true;
input int      DefaultPips                            = 40;
input int      Glubina                                = 24;
input int      DEL                                    = 3;
input int      slip                                   = 3;
input int      MagicNumber                            = 2222;
input bool     Hide_OrderComment                      = false;
input bool     Use_Basket_StopLoss                    = false;
input double   Basket_StopLoss_Money                  = 650.0;
input bool     Use_DrawDown_EmailAlert                = true;
input double   Email_When_DrawDown_Greater_Than       = 15.0;
input int      AccountMaxTrades                       = 250;
input int      MaxTrades                              = 7;
input bool     UseEquityStop                          = false;
input double   TotalEquityRisk                        = 20.0;
input bool     FreezeAfterTP                          = false;
input bool     ShowTradeComment                       = true;
input string   New_Martingale_Setting                 = "------------New_Martingale_Setting-------------";
input bool     Use_Average_Martingale                 = true;
input double   Entry_Percent                          = 0.1;
input bool     Use_Average_PercentTarget              = true;
input double   Average_PercentTarget                  = 0.1;
input string   Trailing_Setting                       = "------------Trailing_Setting-------------";
input bool     Use_Trailing                           = true;
input int      TrailingStart                          = 70;                         //---->TrailingStart
input int      TrailingStop                           = 50;                         //---->TrailingStop
input int      TrailingStep                           = 10;                         //---->TrailingStep
input string   MA_Filter_Setting                      = "------------MA_Filter_Setting-------------";
input bool     Use_MA_filter                          = true;
input ENUM_TIMEFRAMES MA_TimeFrame                    = PERIOD_CURRENT;             //---->MA_TimeFrame
input int      MA_Period                              = 20;                         //---->MA_Period
input ENUM_MA_METHOD MA_Method                        = MODE_SMA;                   //---->MA_Method
input ENUM_APPLIED_PRICE MA_Price                     = PRICE_CLOSE;                //---->MA_Price
input int      MA_Shift                               = 1;                          //---->MA_Shift

double MaximumRisk                                    = 0.02;

double trade_point = Point;

datetime candletime=0;
double stoplevel,Upper_stoplevel,Lower_stoplevel;
datetime EaStartTime=TimeCurrent();
double MaxLot=0.64; //Maximum Lot size To Use
double lotsize;

double AcctBalance = 0.0;
bool   Go          = true;
double LS         = 0.01;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   AcctBalance=AccountBalance();
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   Print("AcctBalance :" + AcctBalance);
   if(OrdersTotal()==0 && AcctBalance!=AccountBalance())
     {
      if(AcctBalance>AccountBalance())
        {
         FixLot=LotExponent*FixLot;
         Go = true;
        }
      else if(AcctBalance<AccountBalance())
        {
         FixLot=LS;
         Go = true;
        }
     }
   //else if(OrdersTotal()==0 && AcctBalance==AccountBalance())
   //  {
   //   Go=true;
   //  }

   if(OrdersTotal()==0 && Go)
     {
      AcctBalance=AccountBalance();
      int order;
      
      //=================Change this with your own entry analysis=============================
     
      //======================================================================================

      double MACurr = iMA (Symbol(),PERIOD_CURRENT,MA_Period,MA_Shift,MA_Method,MA_Price,1);    //MA Current is the MA value in the last closed candle (1)
      double RSI0   = iRSI(NULL,0,RSIPer,RSI_Price,0);
      double RSI1   = iRSI(NULL,0,RSIPer,RSI_Price,1);
      
      if(RSI0 > 30 && RSI1 < 30 && Close[1]< MACurr) //Change this with your buy condition
        {
         order=OrderSend(Symbol(),OP_BUY,FixLot,Ask,0,Bid-Basket_StopLoss_Money*Point,Ask+FixTP*Point);
         Go=false;
        }
      else if(RSI0 < 70 && RSI1 > 70 && Close[1] > MACurr) //Change this with your sell condition
        {
         order=OrderSend(Symbol(),OP_SELL,FixLot,Bid,0,Ask+Basket_StopLoss_Money*Point,Bid-FixTP*Point);
         Go=false;
        }
     }
   if(Use_Trailing)           TrailStop();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open TrailingStop entry Function                               |
//+------------------------------------------------------------------+

void TrailStop(){   
   int Res = 0;
   double SLPrice = 0;
   double NewSL   = 0;
   double Range   = 0;
   int    digit   = 0;
   for (int cnt = 0; cnt < OrdersTotal(); cnt++)
      if( OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){            
         while(IsTradeContextBusy()) Sleep(100); 
         if (OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber){
            Range = MarketInfo(OrderSymbol(),MODE_BID) - OrderOpenPrice();                     
            NewSL = MarketInfo(OrderSymbol(),MODE_BID) - TrailingStop * trade_point;
            NewSL = NormalizeDouble(NewSL,Digits);
            if (Range >= TrailingStart*trade_point)
               if ( NewSL - OrderStopLoss() >= TrailingStep*trade_point ){                     
                  Res = OrderModify (OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,clrNONE);                     
               }
         } 
         if (OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber){
            Range = OrderOpenPrice() - MarketInfo(OrderSymbol(),MODE_ASK);
            NewSL = MarketInfo(OrderSymbol(),MODE_ASK) + TrailingStop*trade_point;
            NewSL = NormalizeDouble(NewSL,Digits );
            if (Range >= TrailingStart*trade_point) 
               if (OrderStopLoss() - NewSL >= TrailingStep*trade_point || OrderStopLoss() == 0){                  
                  Res = OrderModify ( OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,clrNONE);                     
               }
         }
     }      
}
