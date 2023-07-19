//+------------------------------------------------------------------+
//|                                             JK_expertadvisor.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
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
input int      FixTP                                  = 50;
input int      RSIPer                                 = 9;
input ENUM_APPLIED_PRICE RSI_Price                    = PRICE_CLOSE;             //RSI_Price
input bool     Use_Breakeven_Level                    = true;
input int      Breakeven_Level                        = 20;
input double   Breakeven_Point                        = 1.0;
input string   LT001                                  = "======MONEYMANAGEMENT MODULE======";
input int      LotVariant                             = 3;
input double   FixLot                                 = 0.01;
input int      MoneyForOneLot                         = 300;
input MoneyForOneLotTypeSetting MoneyForOneLot_Type   = Balance;                 //MoneyForOneLot_Type
input int      lotdecimal                             = 2;
input string   Lots015                                = "==================";
input double   LotExponent                            = 1.5;
input bool     DynamicPips                            = true;
input int      DefaultPips                            = 40;
input int      Glubina                                = 24;
input int      DEL                                    = 3;
input int      slip                                   = 3;
input int      MagicNumber                            = 2222;
input bool     Hide_OrderComment                      = false;
input bool     Use_Basket_StopLoss                    = false;
input double   Basket_StopLoss_Money                  = 50.0;
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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   bool signal = false;
   AddOrder(signal);
   //--- New Candle Filter
   bool IsNewBar = Time[0] > candletime;

   //--- Spread Filter
   bool IsSpreadGood=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)<(slip*10);
   if(IsSpreadGood==false) Print("Current Spread is greater than the spread put in EA inputs");

   double val   = iCustom(Symbol(),0,"jack_indicator",2,0,0);
   double RSI0  = iRSI(NULL,0,RSIPer,RSI_Price,0);
   double RSI1  = iRSI(NULL,0,RSIPer,RSI_Price,1);
   //--- Trading Rules
   if(IsNewBar && IsSpreadGood && Count(0)+Count(1)<MaxTrades && signal==false){     
      if(RSI0 > 30 && RSI1 < 30) {OpenOrder(0); candletime=Time[0];}
      if(RSI0 < 70 && RSI1 > 70) {OpenOrder(1); candletime=Time[0];}
   }
   if(Use_Trailing)           TrailStop(); 
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Open Orders Counting Function                                    |
//+------------------------------------------------------------------+
int Count(int Type){  
   int count=0;
   for(int i=0; i<=OrdersTotal()-1; i++){     
      bool Select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(Select && OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber && OrderType()==Type) count++;
   }
   return (count);
}

//+------------------------------------------------------------------+
//| Open Pending Orders Function                                     |
//+------------------------------------------------------------------+
double OpenOrder(int Type , double lot =0){  
   
   double openprice=0; 
   double stoploss=0; 
   double takeprofit=0; 
   double Lot=FixLot; 
   double lots[]; 
   LotSizeCalc(lots);
   
   if(_Point==0.00001 || _Point==0.001){     
      stoploss=(Basket_StopLoss_Money*10)*_Point;
      takeprofit=(FixTP*10)*_Point;
   }
   if(_Point==0.0001 || _Point==0.01){     
      stoploss=(Basket_StopLoss_Money)*_Point;
      takeprofit=(FixTP)*_Point;
   }
   if(lots[losscnt()]>=MaxLot){     
      EaStartTime=TimeCurrent();
      return 0;
   }
   if(Type==OP_BUY){     
      openprice=Ask;
      if(Basket_StopLoss_Money>0) stoploss=openprice-stoploss;
      if(FixTP>0) takeprofit=openprice+takeprofit;
   }
   if(Type==OP_SELL){     
      openprice=Bid;
      if(Basket_StopLoss_Money>0) stoploss=openprice+stoploss;
      if(FixTP>0) takeprofit=openprice-takeprofit;
   }
   if(Lot>PrevOrderLot()) lotsize=Lot;
   if(lot>0)Lot = lot;
   if(Lot>MaxLot) Lot=FixLot;
   
   Alert("Buy Signal -> " + "openprice : " + openprice + "," + "stoploss : " + stoploss + "," + "takeprofit : " + takeprofit );
   Print("LotSize", Lot);
   int Ticket=OrderSend(_Symbol,Type,Lot,openprice,300,stoploss,takeprofit,"Order Placed",MagicNumber,0,Type == 0 ? Blue: Red);

   return(Ticket);
}
//+------------------------------------------------------------------+
//| Indicator Moving Average Function                                |
//+------------------------------------------------------------------+
double MAvg(int shift){  
   double MA=iMA(_Symbol,0,MA_Period,MA_Shift,MA_Method,MA_Price,shift);
   return (MA);
  
}
//+------------------------------------------------------------------+
//| Martingale LotSize Calculation Function                           |
//+------------------------------------------------------------------+
void LotSizeCalc(double &arr[]){  
   ArrayResize(arr,100,0);
   arr[0]=FixLot;
   for(int i=1;i<ArraySize(arr);i++){     
      arr[i]=arr[i-1]*LotExponent;
   }
}

//+------------------------------------------------------------------+
//| Orders WinCount & LossCount Function                             |
//+------------------------------------------------------------------+
int losscnt(){  
   int WinCount=0;
   int Losscnt=0;
   for(int Count=OrdersTotal()-1;Count>=0; Count--){     
      bool select=OrderSelect(Count,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderType()<=1 && OrderOpenTime()>=EaStartTime){        
         if(OrderProfit()>0 && Losscnt==0) WinCount++;
         else if(OrderProfit()<0 && WinCount==0) Losscnt++;
         else break;
      }
   }
   return(WinCount);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open Orders Lot Selecting Function                               |
//+------------------------------------------------------------------+
double PrevOrderLot(){  
   double lot=0;
   for(int i=OrdersTotal()-1;i>=0;i--){     
      bool Select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(Select && OrderSymbol()==_Symbol && OrderType()<=1 && OrderMagicNumber()==MagicNumber){       
        lot=OrderLots();
        break;
     }
   }
   return (lot);
}
  
struct COrders{  
   int ticket;
   double lots;
   bool Istradeopen;
}orders[];


bool IsTicketAlreadyExist(int ticket){
   bool signal = false;
   for(int i=0;i<ArraySize(orders);i++){  
      if(ticket ==  orders[i].ticket){        
        signal=true;
        break;
      }
   }
   return(signal);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open Add Order Function                               |
//+------------------------------------------------------------------+

void AddOrder(bool &signal){
   static datetime timer=TimeCurrent();
   signal=false;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--){  
      bool select = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      
      Print("timer = " + timer);
      Print("OrderCloseTime = " + OrderCloseTime());
      if(select && OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderCloseTime()>=timer && OrderProfit()+OrderSwap()+OrderCommission()>0){        
         if(IsTicketAlreadyExist(OrderTicket())==false){           
            ArrayResize(orders,ArraySize(orders)+1,0);
            orders[ArraySize(orders)-1].ticket=OrderTicket();
            orders[ArraySize(orders)-1].lots=OrderLots();
            orders[ArraySize(orders)-1].Istradeopen=false;
         }
      }
   }
   if(ArraySize(orders)>0){  
      static datetime timecandle = Time[0];
      bool IsNewBar = Time[0]>timecandle;
      
      if(IsNewBar){        
         int index =-1;
         double highest_lot = GetHighestOrderLotFromArray(index);
         double RSI0  = iRSI(NULL,0,RSIPer,RSI_Price,0);
         double RSI1  = iRSI(NULL,0,RSIPer,RSI_Price,1);
      
         if(highest_lot >0){          
             if(Close[1]>MAvg(1) && RSI0 > 30 && RSI1 < 30) OpenOrder(0,NormalizeDouble(highest_lot*1.5,2));
             if(Close[1]<MAvg(1) && RSI0 < 70 && RSI1 > 70) OpenOrder(1,NormalizeDouble(highest_lot*1.5,2));
             
             //RSI0 > buy_level && RSI1 < buy_level && Open[1] < MACurr && Close[1]< MACurr
             
             
             orders[index].Istradeopen=true;
             signal=true;
             candletime=Time[0];
         }        
         timecandle=Time[0];
      }  
   }
}

double GetHighestOrderLotFromArray(int &index ){
   double h_lot =0;   
   for(int i=0;i<ArraySize(orders);i++){     
      if(orders[i].lots>h_lot && orders[i].Istradeopen==false){        
         h_lot=orders[i].lots;
         index=i;
      }
   }
   return(h_lot);
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
