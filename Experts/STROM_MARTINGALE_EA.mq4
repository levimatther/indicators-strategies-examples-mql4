//+-------------------------------------------------------------------+
//|                                           STROM MARTINGALE EA.mq4 |
//|                                      Email: skilful_coder@mail.ru |
//|                            Beknazarov Hasanboy, Uzbekistan © 2017 |
//+-------------------------------------------------------------------+
#property copyright "skilful_coder ( from MQL5.com ) © 2017"
#property link "https://www.mql5.com/en/users/skilful_coder/portfolio"
#property version "1.20"
#property strict
#include <stderror.mqh> 
#include <stdlib.mqh> 
enum trade{ 
 a=0//BB
,b=1//EMA
,c=2//100 pips
};
enum Mart{ 
 d=0//Pips
,e=1//Next candle
};

enum direct{ 
 f=0//Buy
,g=1//Sell
,h=2//Buy & Sell
,j=3//None
};

enum Marti{ 
 k=0//From 2 order
,l=1//From 3 order
};
      string NameEA                           ="STROM MARTINGALE EA v2";//Order Comment
input double SLinMoney                        = 10;           //SL in Money
input double TPinMoney                        = 10;           //TP in Money
input int    MagicNumber                      = 123;          //Magic Number
input trade  TradeOpen                        = 0;            //Logic
input double FixedLot                         = 0.01;         //Initial lots
input double MinGrid                          = 300;          //Min.Grid 
input double GridMulti                        = 1;            //Grid Multi
input Mart   MartType                         = 0;            //Martingale logic
input double MartMulti                        = 1.486;        //Mart Multi
input Marti  MartType2                        = 0;            //Type of Mart Multi
input int    MaxOpenOrders                    = 8;            //Max Matingale Steps
input bool   EnableTimer1                     = 0;            //Use Trade Time 1
input string Timer1Start                      = "04:00";      //Time Start 1
input string Timer1End                        = "21:30";      //Time End 1
input bool   EnableTimer2                     = 0;            //Use Trade Time 2
input string Timer2Start                      = "00:00";      //Time Start 2
input string Timer2End                        = "00:00";      //Time End 2
input direct Direction                        = 2;            //Direction Allowed
input int    Slippage                         = 3;            //Slippage    
input bool   Commentary                       = 1;            //Comment on chart
input color  Box_Background_Color             = clrWhiteSmoke;//Box Color
input string ____________________________3____="=============================================================================";//__________BBands settings
input int    Symbol_1_Kod                     = 20;           //Period
input double Symbol_2_Kod                     = 1.5;          //Deviation
input string ____________________________4____="==============================================================================";//___________EMA 1 settings
input int    MA_Period1                       = 8;            //Period  
input ENUM_MA_METHOD MA_Method1               = MODE_EMA;     //Method 
input ENUM_APPLIED_PRICE MA_Price1            = PRICE_TYPICAL;//Price 
input string ____________________________5____="==============================================================================";//___________EMA 2 settings
input int    MA_Period2                       = 11;           //Period 
input ENUM_MA_METHOD MA_Method2               = MODE_EMA;     //Method 
input ENUM_APPLIED_PRICE MA_Price2            = PRICE_TYPICAL;//Price 
input string ____________________________6____="==============================================================================";//___________EMA 3 settings
input int    MA_Period3                       = 14;           //Period 
input ENUM_MA_METHOD MA_Method3               = MODE_EMA;     //Method 
input ENUM_APPLIED_PRICE MA_Price3            = PRICE_TYPICAL;//Price
input string ____________________________7____="=============================================================================";//_100pips Momentum settings
input int    Period2                          = 15;           //Period
      double StopLoss                         = 0;            //Stop Loss
      double TakeProfit                       = 0;            //Take Profit
      color  CommColor                        = clrBlue;      //Info Text Color
      int    InfoCorner                       = 0;            //Info Text Corner
      int    Ymove                            = 32;           //Y position
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
datetime B,S;
string prefix="",text[15];  
int    PipValue=1,digit_lot=0;
bool   Buy=0,Sell=0,Buy2=0,Sell2=0,Buy3=0,Sell3=0;
double ClosingArray[100],Lotb,Lots,Sloss,Tprof,point,mingr,
       LastPriceB,LastPriceS,AllProfitB,AllProfitS,LastLotB,LastLotS;
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit(){
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==1) digit_lot=0;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1) digit_lot=1;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01) digit_lot=2;

   if(_Digits==4 || (Bid<1000 && _Digits==2)){ PipValue=1;} 
   else PipValue=10;
   
   if(_Digits==1) point = 1; //CFD 
   if(_Digits==0) point = 1; //Indexes   
   if(_Digits==4 || _Digits==5) point = 0.0001; 
   if((_Digits==2 || _Digits==3) && Bid>1000) point = 1;
   if((_Digits==2 || _Digits==3) && Bid<1000) point = 0.01;
   if(StringFind(_Symbol,"XAU")>-1 || StringFind(_Symbol,"xau")>-1 || 
   StringFind(_Symbol,"GOLD")>-1) point = 0.1;//Gold 
   
   if(IsTesting()) prefix="Test"+IntegerToString(MagicNumber)+Symbol();
   else prefix=IntegerToString(MagicNumber)+Symbol(); MakeLabel();    
   return;
   }   
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
 if(IsTesting()){GVDel(prefix);}
 return;
} 
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO//
//+------------------------------------------------------------------+
//|  Get Signals                                                     |
//+------------------------------------------------------------------+
double BBup(int shift){ 
double val = iBands(NULL,0,Symbol_1_Kod,Symbol_2_Kod,0,PRICE_CLOSE,MODE_UPPER,shift);
return(val);} 

double BBdn(int shift){ 
double val = iBands(NULL,0,Symbol_1_Kod,Symbol_2_Kod,0,PRICE_CLOSE,MODE_LOWER,shift);
return(val);} 

double EMA1(int shift){ 
double val = iMA(NULL,0,MA_Period1,0,MA_Method1,MA_Price1,shift);
return(val);}  
 
double EMA2(int shift){ 
double val = iMA(NULL,0,MA_Period2,0,MA_Method2,MA_Price2,shift);
return(val);} 

double EMA3(int shift){ 
double val = iMA(NULL,0,MA_Period3,0,MA_Method3,MA_Price3,shift);
return(val);} 

double Mom(int buff, int shift){ 
double val = iCustom(Symbol(),0,"100pips Momentum_1.4",1,Period2," ",0,0,0," ",buff,shift);
return(val);} 
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  
//+------------------------------------------------------------------+
//|  Open Rules                                                      |
//+------------------------------------------------------------------+
void Indicators() 
{      
   Buy   = (BBdn(1) > iClose(NULL,0,1) && BBdn(1) < iOpen(NULL,0,1)); 
   Sell  = (BBup(1) < iClose(NULL,0,1) && BBup(1) > iOpen(NULL,0,1));  
   
   Buy2  = (EMA1(1) > EMA2(1) && EMA2(1) > EMA3(1)); 
   Sell2 = (EMA1(1) < EMA2(1) && EMA2(1) < EMA3(1));    
   
   Buy3  = (Mom(4,1) != EMPTY_VALUE && Mom(4,2) == EMPTY_VALUE); 
   Sell3 = (Mom(5,1) != EMPTY_VALUE && Mom(5,2) == EMPTY_VALUE);  
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH 
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
void OnTick(){

     LotsSize();
     Indicators();
     PrintInfoToChart();
     int num = Orders(-1);
     if(num < 1){GVSet("buy",0);GVSet("sell",0);}
     
     LastPriceB = FindLastOrderParameterB("price");
     LastPriceS = FindLastOrderParameterS("price");
     //if(AllProfitB < 0){Lotb = NormalizeDouble(LastLotB*MartMulti, digit_lot);}
     double grid = MinGrid; int loss = Orders(-1);  
   
   if(GridMulti > 0 && loss > 0){ grid = NormalizeDouble(MinGrid * MathPow(GridMulti, loss), 1);}
//+------------------------------------------------------------------------------------------------------------------------------+
     if(MathAbs(CheckProfit(-1)) > SLinMoney && CheckProfit(-1) < 0 && SLinMoney != 0)
       {
        GVSet("loss",1);
       }  
//+------------------------------------------------------------------------------------------------------------------------------+
     if(GVGet("loss")==1 && SLinMoney != 0)
       {
        if(CloseOrders(-1)){GVSet("loss",0);Print("-----> Package closed !");}
       }     
//+------------------------------------------------------------------------------------------------------------------------------+                
     if(CheckProfit(-1) > TPinMoney && TPinMoney != 0)
       {
        GVSet("profit",1);
       }    
//+------------------------------------------------------------------------------------------------------------------------------+                
     if(GVGet("profit")==1 && TPinMoney != 0)
       {
        if(CloseOrders(-1)){GVSet("profit",0);Print("-----> Package closed !");}
       }  
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO    
     bool band = 0,ban = 0;
     for(int i = OrdersTotal() - 1; i >= 0; i--)
    	 if(OrderSelect (i, SELECT_BY_POS)){        
	    if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment()==NameEA+(string) 1){
       if(OrderOpenTime() >= iTime(NULL,0,0))ban = true;}}
       if(ban){return;} 
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      
     for(int i=OrdersHistoryTotal()-1;i>=0;i--){
       if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){ 
       Print("Error in history!"); break;}
       if(OrderSymbol()!= Symbol() || OrderType() > OP_SELL) continue;
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment()==NameEA+(string) 1){
       if(OrderOpenTime() >= iTime(NULL,0,0))band = true;}}
       if(band){return;} 
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==0 && GoodTime() && MartType==1){     
        if(Buy && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }}  
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==1 && GoodTime() && MartType==1){     
        if(Buy2 && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell2 && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }}  
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==2 && GoodTime() && MartType==1){     
        if(Buy3 && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell3 && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }} 
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < MaxOpenOrders+1 && GoodTime() && MartType==1){     
        if(B+0.1 < TimeCurrent() && GVGet("buy")==1 && Direction != 3 && (Direction==0 || Direction==2) && LastPriceB-grid*Point > Ask){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrGreen);
        if(Tiketb > 0){B=TimeCurrent();}
        }  
        if(S+0.1 < TimeCurrent() && GVGet("sell")==1 && Direction != 3 && (Direction==1 || Direction==2) && LastPriceS+grid*Point < Bid){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 1,MagicNumber,0,clrMagenta);
        if(Tikets > 0){S=TimeCurrent();}
        }}           
        
        
        
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==0 && GoodTime() && MartType==0){     
        if(Buy && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }}  
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==1 && GoodTime() && MartType==0){     
        if(Buy2 && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell2 && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }}  
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < 1 && TradeOpen==2 && GoodTime() && MartType==0){     
        if(Buy3 && GVGet("buy")==0 && Direction != 3 && (Direction==0 || Direction==2)){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrBlue);
        if(Tiketb > 0){GVSet("buy",1);B=TimeCurrent();}
        }  
        if(Sell3 && GVGet("sell")==0 && Direction != 3 && (Direction==1 || Direction==2)){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrRed);
        if(Tikets > 0){GVSet("sell",1);S=TimeCurrent();}
        }} 
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              
       if(num < MaxOpenOrders+1 && MartType==0){     
        if(B+0.1 < TimeCurrent() && GVGet("buy")==1 && Direction != 3 && (Direction==0 || Direction==2) && LastPriceB-grid*Point > Ask){
        if(StopLoss == 0){Sloss = 0;}else{
        Sloss = Ask - StopLoss * point;}
        if(TakeProfit == 0){Tprof = 0;}else{ 
        Tprof = Ask + TakeProfit * point;} 
        int Tiketb = OrderSend(Symbol(),OP_BUY,Lotb,Ask,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrGreen);
        if(Tiketb > 0){B=TimeCurrent();}
        }  
        if(S+0.1 < TimeCurrent() && GVGet("sell")==1 && Direction != 3 && (Direction==1 || Direction==2) && LastPriceS+grid*Point < Bid){ 
        if(StopLoss == 0){Sloss = 0;}else{ 
        Sloss = Bid + StopLoss * point;} 
        if(TakeProfit == 0){Tprof = 0;}else{  
        Tprof = Bid - TakeProfit * point;}
        int Tikets = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage*PipValue,Sloss,Tprof,NameEA+(string) 2,MagicNumber,0,clrMagenta);
        if(Tikets > 0){S=TimeCurrent();}
        }}   
  return;
} 
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
//| Print info to chart                                              |
//+------------------------------------------------------------------+
void PrintInfoToChart()
{
  string Direc,Direc2;
  if(Direction==2){Direc="L & S";}
  if(Direction==0){Direc="L";}
  if(Direction==1){Direc="S";}
  if(Direction==3){Direc="None";}
  
  if(TradeOpen==0){Direc2="BB";}
  if(TradeOpen==1){Direc2="EMA";}
  if(TradeOpen==2){Direc2="100 pips";}
  if(Commentary){    
    text[1]= "---------------------------------------";
    text[2]= "STROM Martinagle EA v1.00"; 
    text[3]= "Direction: " + Direc; 
    text[4]= "Logic: " + Direc2;
    text[5]= "MinGrid: " + DoubleToStr(MinGrid, 2);
    text[6]= "TP in money: " + DoubleToStr(TPinMoney, 2);
    text[7]= "Current Profit: " + DoubleToStr(CheckProfit(-1), 2);  
    text[8]= "Magic Number: " + IntegerToString(MagicNumber, 2);
    text[9]= "---------------------------------------";    
    int i=1, k=Ymove;
    while (i<=14)
    {
       string ChartInfo = DoubleToStr(i, 0);
       ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetText(ChartInfo, text[i], 9, "Arial", CommColor);
       ObjectSet(ChartInfo, OBJPROP_CORNER, InfoCorner);   
       ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);  
       ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
       i++;
       k=k+13;
}}}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
void MakeLabel()
{
   //Create Background Box
   string gs = "g"; for (int i=1; i<1; i++) gs = gs + "g";
   string Box = "B2";       
   ObjectCreate(Box, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSetText(Box, gs, 120, "Webdings");
   ObjectSet(Box, OBJPROP_CORNER, 0);
   ObjectSet(Box, OBJPROP_XDISTANCE, 1);
   ObjectSet(Box, OBJPROP_YDISTANCE, 13);   
   ObjectSet(Box, OBJPROP_COLOR, Box_Background_Color);
   ObjectSet(Box, OBJPROP_BACK, FALSE);
         
   //End of program computations   
   return;
   }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//+------------------------------------------------------------------+
//|  LotsSize                                                        |
//+------------------------------------------------------------------+
void LotsSize(){       
     Lotb = FixedLot;
     Lots = FixedLot;
     int num = Orders(-1);
     AllProfitB = FindLastOrderParameterB("profit"); 
     LastLotB = FindLastOrderParameterB("lot"); 
     AllProfitS = FindLastOrderParameterS("profit"); 
     LastLotS = FindLastOrderParameterS("lot"); 
     
     if(AllProfitB < 0 && MartType2==0){Lotb = NormalizeDouble(LastLotB*MartMulti, digit_lot);}  
     if(AllProfitS < 0 && MartType2==0){Lots = NormalizeDouble(LastLotS*MartMulti, digit_lot);}  
     if(AllProfitB < 0 && MartType2==1 && num > 1){Lotb = NormalizeDouble(LastLotB*MartMulti, digit_lot);}  
     if(AllProfitS < 0 && MartType2==1 && num > 1){Lots = NormalizeDouble(LastLotS*MartMulti, digit_lot);} 
     if(Lotb < MarketInfo(Symbol(),MODE_MINLOT)) Lotb = MarketInfo(Symbol(),MODE_MINLOT);
     if(Lotb > MarketInfo(Symbol(),MODE_MAXLOT)) Lotb = MarketInfo(Symbol(),MODE_MAXLOT);
     if(Lots < MarketInfo(Symbol(),MODE_MINLOT)) Lots = MarketInfo(Symbol(),MODE_MINLOT);
     if(Lots > MarketInfo(Symbol(),MODE_MAXLOT)) Lots = MarketInfo(Symbol(),MODE_MAXLOT);}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check $ Profit                                                   |
//+------------------------------------------------------------------+     
double CheckProfit(int type) //-1= All,0=Buy,1=Sell;
 {
     double Profitb=0,Profits=0;       
     for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool os = OrderSelect(i,SELECT_BY_POS);            
       if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
       {        
        if(OrderType()==OP_BUY){ Profitb+=OrderProfit()+OrderSwap()+OrderCommission();} 
        if(OrderType()==OP_SELL){ Profits+=OrderProfit()+OrderSwap()+OrderCommission();} 
       }} 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
 }      
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| Get total order                                                  |
//+------------------------------------------------------------------+
int Orders(int type)
{
   int count=0;
   //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=AllBuy,7=AllSell,8=AllMarket,9=AllPending;   
   for(int x=OrdersTotal()-1;x>=0;x--)
      {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)){ 
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
        {
         if(type < 0){ count++;}
         if(OrderType() == type && type >= 0){ count++;}  
         if(OrderType() <= 1 && type == 8){ count++;}  
         if(OrderType() > 1 && type == 9){ count++;}  
         if((OrderType() == 0 || OrderType() == 2 || OrderType() == 4) && type == 6){ count++;}
         if((OrderType() == 1 || OrderType() == 3 || OrderType() == 5) && type == 7){ count++;}       
         }}}   
   return(count);
}             
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------+
//|  Close Orders                                              |
//+------------------------------------------------------------+  
bool CloseOrders(int type)
{ //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=All Buys,7=All Sells,8=All Market,9=All Pending;
  bool oc=0;    
  for(int i=OrdersTotal()-1;i>=0;i--){
  bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
  if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber))
    {   
     if(type==-1){
     if(OrderType()==0){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}
     if(OrderType()==1){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}      
     if(OrderType()>1){ oc = OrderDelete(OrderTicket());}}  
     if(OrderType()>1 && type==9){ oc = OrderDelete(OrderTicket());} 
     if(OrderType()<=1 && type==8){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}
     if(OrderType()==type && type==0){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}
     if(OrderType()==type && type==1){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);} 
     if(OrderType()==type && OrderType()> 1){ oc = OrderDelete(OrderTicket());} 
     if(OrderType()==0 && type==6){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}  
     if((OrderType()==2 || OrderType()== 4) && type==6){ oc = OrderDelete(OrderTicket());}   
     if(OrderType()==1 && type==7){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}  
     if((OrderType()==3 || OrderType()== 5) && type==7){ oc = OrderDelete(OrderTicket());}       
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(oc);
}      
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH   
//+----------------------------------------------------------------------------------+
//| Time limited trading                                                             |
//+----------------------------------------------------------------------------------+  
bool GoodTime()
 {
  if(!EnableTimer1 && !EnableTimer2)return(true);
  if(EnableTimer1 || EnableTimer2)
    {
    if(TimeCurrent() > StrToTime(Timer1Start) && TimeCurrent() < StrToTime(Timer1End) && EnableTimer1)
    return(true);
    if(TimeCurrent() > StrToTime(Timer2Start) && TimeCurrent() < StrToTime(Timer2End) && EnableTimer2)
    return(true);
    }
    return(false);
 }        
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
double FindLastOrderParameterB(string ParamName){
  double mOrderPrice = 0, mOrderLot = 0, mOrderProfit = 0;
  int PrevTicket = 0, CurrTicket = 0, mOrderTicket = 0;
  datetime tim = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType()==OP_BUY){
        CurrTicket = OrderTicket();
        if (CurrTicket > PrevTicket){
          PrevTicket = CurrTicket;
          tim = OrderOpenTime();
          mOrderPrice = OrderOpenPrice();
          mOrderTicket = OrderTicket();
          mOrderLot = OrderLots();
          mOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();}}   
  if(ParamName == "price") return(mOrderPrice);
  else if(ParamName == "ticket") return(mOrderTicket);
  else if(ParamName == "lot") return(mOrderLot);
  else if(ParamName == "profit") return(mOrderProfit);
  else if(ParamName == "tm") return((int)tim);
  return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
double FindLastOrderParameterS(string ParamName){
  double mOrderPrice = 0, mOrderLot = 0, mOrderProfit = 0;
  int PrevTicket = 0, CurrTicket = 0, mOrderTicket = 0;
  datetime tim = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType()==OP_SELL){
        CurrTicket = OrderTicket();
        if (CurrTicket > PrevTicket){
          PrevTicket = CurrTicket;
          tim = OrderOpenTime();
          mOrderPrice = OrderOpenPrice();
          mOrderTicket = OrderTicket();
          mOrderLot = OrderLots();
          mOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();}}   
  if(ParamName == "price") return(mOrderPrice);
  else if(ParamName == "ticket") return(mOrderTicket);
  else if(ParamName == "lot") return(mOrderLot);
  else if(ParamName == "profit") return(mOrderProfit);
  else if(ParamName == "tm") return((int)tim);
  return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH   
//+------------------------------------------------------------------+
//|  Global Variable Set                                             |
//+------------------------------------------------------------------+  
datetime GVSet(string name,double value)
  {
   return(GlobalVariableSet(prefix+name,value));
  }
//+------------------------------------------------------------------+
//|  Global Variable Get                                             |
//+------------------------------------------------------------------+
double GVGet(string name)
  {
   return(GlobalVariableGet(prefix+name));
  }
//+------------------------------------------------------------------+
//|  Global Variable Delete                                          |
//+------------------------------------------------------------------+
bool GVDel(string pref)
  {
   for(int tries=0; tries<10; tries++)
     {
      int obj=GlobalVariablesTotal();
      for(int o=0; o<obj;o++)
        {
         string name=GlobalVariableName(o);
         int index=StringFind(name,pref,0);
         if(index>-1)
            GlobalVariableDel(name);
        }
     }
   return(0);  
  }    
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM