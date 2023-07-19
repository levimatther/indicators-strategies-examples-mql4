//+------------------------------------------------------------------+
//|                                                   Sum_RSI_EA.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input bool   OpenBUY       = True;
input bool   OpenSELL      = True;
input bool   CloseBySignal = True;
input double StopLoss      = 50;
input double TakeProfit    = 50;
input double TrailingStop  = 5;
input int    RSIperiod     = 14;
input double RSILowerBand  = 30;
input double RSIUpperBand  = 70;
input double Risk          = 10;
input double ManualLots    = 0.1;
input int    MagicNumber   = 16384;
input string Koment        = "RSIea";
input int    Slippage      = 1;
input ENUM_APPLIED_PRICE RSIAppliedPrice = PRICE_CLOSE;             //RSI Applied Price


//---
bool     AutoLot       = false;
int      OrderBuy, OrderSell;
int      ticket;
int      LotDigits;
double   Trail, iTrailingStop;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){  
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit(){  
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(){  
   double stoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL);
   OrderBuy  = 0;
   OrderSell = 0;
   for(int cnt=0; cnt<OrdersTotal(); cnt++){     
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == Koment){           
            if(OrderType() == OP_BUY)  OrderBuy ++;
            if(OrderType() == OP_SELL) OrderSell ++;
            if(TrailingStop > 0){              
               iTrailingStop = TrailingStop;
               if(TrailingStop < stoplevel) iTrailingStop = stoplevel;
               Trail = iTrailingStop * Point;
               double tsbuy  = NormalizeDouble(Bid - Trail, Digits);
               double tssell = NormalizeDouble(Ask + Trail, Digits);
               if(OrderType() == OP_BUY && Bid-OrderOpenPrice()>Trail && Bid-OrderStopLoss()>Trail){                 
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),tsbuy,OrderTakeProfit(),0,Blue);
               }
               if(OrderType() == OP_SELL && OrderOpenPrice()-Ask>Trail && (OrderStopLoss()-Ask>Trail || OrderStopLoss()==0)){                 
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),tssell,OrderTakeProfit(),0,Blue);
               }
           }
       }
   }
   double rsi  = iRSI(Symbol(),0,RSIperiod,RSIAppliedPrice,0);
   double rsi1 = iRSI(Symbol(),0,RSIperiod,RSIAppliedPrice,1);
   // double HTb=iCustom(Symbol(),0,"HalfTrend-1.02",0,0); //buy
   // double HTs=iCustom(Symbol(),0,"HalfTrend-1.02",1,0); //buy
   //--- open position
   if (OpenSELL && OrderSell<1 && rsi<RSIUpperBand && rsi1>RSIUpperBand && Open[1]<Close[1] && Open[0]>Close[0])  OPSELL();
   if (OpenBUY  && OrderBuy <1 && rsi>RSILowerBand && rsi1<RSILowerBand  && Open[1]>Close[1] && Open[0]<Close[0]) OPBUY();
   //--- close position by signal
   if(CloseBySignal){     
      if(OrderBuy>0  && rsi<RSIUpperBand && rsi1>RSIUpperBand) CloseBuy();
      if(OrderSell>0 && rsi>RSILowerBand && rsi1<RSILowerBand) CloseSell();
   }   
   return ;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPBUY(){
  
   double StopLossLevel;
   double TakeProfitLevel;
   if(StopLoss>0)   StopLossLevel   = Bid - StopLoss*Point;    else StopLossLevel   = 0.0;
   if(TakeProfit>0) TakeProfitLevel = Ask + TakeProfit*Point;  else TakeProfitLevel = 0.0;

   ticket = OrderSend(Symbol(),OP_BUY,LOT(),Ask,Slippage,StopLossLevel,TakeProfitLevel,Koment,MagicNumber,0,DodgerBlue);
   //ticket = OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"Buy",16384,0,Blue);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPSELL(){  
   double StopLossLevel;
   double TakeProfitLevel;
   if(StopLoss > 0)   StopLossLevel   = Ask + StopLoss*Point;    else StopLossLevel   = 0.0;
   if(TakeProfit > 0) TakeProfitLevel = Bid - TakeProfit*Point;  else TakeProfitLevel = 0.0;
//---
   ticket = OrderSend(Symbol(),OP_SELL,LOT(),Bid,Slippage,StopLossLevel,TakeProfitLevel,Koment,MagicNumber,0,DeepPink);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell(){  
   int  total = OrdersTotal();
   for(int y = OrdersTotal()-1; y>=0; y--){     
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber){           
            ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
         }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy(){
  
   int  total = OrdersTotal();
   for(int y = OrdersTotal()-1; y>=0; y--){     
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber){           
            ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
         }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LOT(){  
   double lotsi;
   double ilot_max   = MarketInfo(Symbol(), MODE_MAXLOT);
   double ilot_min   = MarketInfo(Symbol(), MODE_MINLOT);
   double tick       = MarketInfo(Symbol(), MODE_TICKVALUE);

   double  myAccount = AccountBalance();

   if(ilot_min == 0.01)   LotDigits = 2;
   if(ilot_min == 0.1)    LotDigits = 1;
   if(ilot_min == 1)      LotDigits = 0;

   if(AutoLot){     
      lotsi=NormalizeDouble((myAccount*Risk)/10000, LotDigits);
   } else { 
      lotsi = ManualLots;
   }
   if(lotsi >= ilot_max){ 
      lotsi = ilot_max; 
   }
   return(lotsi);
}
//+------------------------------------------------------------------+
