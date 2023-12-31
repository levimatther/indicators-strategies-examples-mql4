//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                               Copyright © 2016, Õëûñòîâ Âëàäèìèð |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Õëûñòîâ Âëàäèìèð"
#property link      "cmillion@narod.ru"
#property strict
#property description "ñîâåòíèê ïî RSI"
#property description "sell ïðè ïåðåñå÷åíèå ñâåðõó âíèç 70 è íà buy ñíèçó ââåðõ 30"
#property description "ñòîïû è òåéêè ìîæíî âûñòîâèòü â íàñòðîéêàõ ñîâåòíèêà"
//--------------------------------------------------------------------
extern int     RSIPer           = 14,
               Basket_StopLoss_Money             = 500,
               FixTP           = 500,
               slip             = 3,
               buy_level            = 30,
               sell_level           = 70,
               MagicNumber                = 777;               

input string   Koment               = "RSIea";
input bool     Use_Trailing         = true;



input int      TrailingStart                          = 70;                         //---->TrailingStart
input int      TrailingStop                           = 50;                         //---->TrailingStop
input int      TrailingStep                           = 10;  
double trade_point = Point;
input double   LotExponent                            = 1.2;
input bool     Use_MA_filter                          = true;
input ENUM_TIMEFRAMES MA_TimeFrame                    = PERIOD_CURRENT;             //---->MA_TimeFrame
input int      MA_Period                              = 20;                         //---->MA_Period
input ENUM_MA_METHOD MA_Method                        = MODE_SMA;                   //---->MA_Method
input ENUM_APPLIED_PRICE MA_Price                     = PRICE_CLOSE;                //---->MA_Price
input int      MA_Shift                               = 1;                          //---->MA_Shift
input double   FixLot                                 = 0.03;
double MaximumRisk                                    = 0.02;
double DecreaseFactor                                 = 3;
double MaxLot=0.64; //Maximum Lot size To Use
datetime EaStartTime=TimeCurrent();
double lotsize;
//--------------------------------------------------------------------


double LotsOptimized(){  
   double lot = FixLot;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
   //--- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
   //--- calcuulate number of losses orders without a break
   if(DecreaseFactor > 0){     
      for(int i=orders-1; i >= 0; i--){        
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){           
            Print("Error in history!");
            break;
         }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
      }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
   }
   //--- return lot size
   if(lot<0.1) lot = 0.1;
   return(lot);
}

void OnTick()
{  
   for (int i=0; i<OrdersTotal(); i++)
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if (OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()) return;
   double MACurr = iMA (Symbol(),PERIOD_CURRENT,MA_Period,MA_Shift,MA_Method,MA_Price,1);    //MA Current is the MA value in the last closed candle (1)
   double RSI0   = iRSI(NULL,0,RSIPer,PRICE_OPEN,0);
   double RSI1   = iRSI(NULL,0,RSIPer,PRICE_OPEN,1);
   double SL=0,TP=0;
   if (RSI0 > buy_level && RSI1 < buy_level && Close[1]< MACurr)
   {
      if (FixTP!=0) TP  = NormalizeDouble(Ask + FixTP*Point,Digits);
      if (Basket_StopLoss_Money!=0)   SL  = NormalizeDouble(Ask - Basket_StopLoss_Money*  Point,Digits);     
      if (OrderSend(Symbol(),OP_BUY, FixLot,NormalizeDouble(Ask,Digits),0,SL,TP,NULL,MagicNumber)==-1) Print(GetLastError());
   }
   if (RSI0 < sell_level && RSI1 > sell_level && Close[1] > MACurr)
   {
      if (FixTP!=0) TP = NormalizeDouble(Bid - FixTP*Point,Digits);
      if (Basket_StopLoss_Money!=0)   SL = NormalizeDouble(Bid + Basket_StopLoss_Money*  Point,Digits);            
      if (OrderSend(Symbol(),OP_SELL,FixLot,NormalizeDouble(Bid,Digits),slip,SL,TP,NULL,MagicNumber)==-1) Print(GetLastError());
   }
   if(Use_Trailing)           TrailStop(); 
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
//| Trailing Stop Function                                     |
//+------------------------------------------------------------------+
void TrailStop(){   
   int Res = 0;
   double SLPrice = 0;
   double NewSL   = 0;
   double Range   = 0;
   int    digit   = 0;
   
   for (int cnt = 0; cnt < OrdersTotal(); cnt++)      
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){  
               
         while(IsTradeContextBusy()) Sleep(100); 
         if (OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber){
            
            Range = MarketInfo(OrderSymbol(),MODE_BID) - OrderOpenPrice();                     
            NewSL = MarketInfo(OrderSymbol(),MODE_BID) - TrailingStop * trade_point;
            NewSL = NormalizeDouble(NewSL,Digits);
            if (Range >= TrailingStart*trade_point)
               Print("Hello Messi");    
               if ( NewSL - OrderStopLoss() >= TrailingStep*trade_point ){                     
                  Res = OrderModify (OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,clrNONE);                     
               }
         } 
         if (OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber){
              
            Range = OrderOpenPrice() - MarketInfo(OrderSymbol(),MODE_ASK);
            NewSL = MarketInfo(OrderSymbol(),MODE_ASK) + TrailingStop*trade_point;
            NewSL = NormalizeDouble(NewSL,Digits );
            if (Range >= TrailingStart*trade_point) 
               Print("Hello Kaka");  
               if (OrderStopLoss() - NewSL >= TrailingStep*trade_point || OrderStopLoss() == 0){                  
                  Res = OrderModify ( OrderTicket(),OrderOpenPrice(),NewSL,OrderTakeProfit(),0,clrNONE);                     
               }
         }
     }      
}