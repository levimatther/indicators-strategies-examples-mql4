//+------------------------------------------------------------------+
//|                                                          NN.mq4  |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Kashif Nawaz"
#property link      "https://www.mql5.com/en/users/kashifnawaz"
#property strict

datetime da=D'2040.12.31 00:00';
extern string EA_Name="GoWithFlow";

extern double lot=0.01; //Lot Size
extern double dis=20; //Grid Distance
extern double Multiplier=1.3;
extern double Spreed=2; //Spread
extern double maxlot1=1.28; //Maximum Lot Size
extern bool tf=false;  //Time Filter
extern string  StartTime="00:00"; //Start Time
extern string  StopTime="23:59"; //End Time
extern string en1="Engine 1"; //Engine 1 (Martingale)
extern double tpp=17; //Take Profit (Pips)
extern double tp=50; //Take Profit $$
extern int mag1=123; //Magic Number
extern string en2="Engine 2"; //Engine 2 (Anti Martingale)
extern int mhl=18; //Martingal Hedge Level
extern int tsl=15; //Trailing SL (Pips)
extern int ts=1; //Trailing Step (Pips)
extern int sl=15; //Stop Loss (Pips)
extern bool hr=true; //Hedge Reborn
extern double maxlot2=1.28; //Maximum Lot Size
extern double al=10000000; //Account Locking($)
extern int mag2=456; //Magic Numberé
extern string Email="eamt4forex@gmail.com";

double point;
bool en=true;
double hbb,blb,hsb,bsl;
double fbl,fsl,hbl,hsl;
bool b2=false,s2=false;
bool shb=false,shs=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Digits==5 || Digits==3)
     {
      point=Point*10;
     }
   else
     {
      point=Point;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
      if(TimeCurrent()>da)
     {
      Alert("EA Expired. Please contact to eamt4forex@gmail.com");
      ExpertRemove();
      return;
     }
//---
   if(((tf && TradeTime()) || tf==false) && (MarketInfo(Symbol(),MODE_SPREAD)/10<=Spreed))
     {
      if(nbuy(mag1)==0)
        {
         fbl=lot;
         blb=0;
         hsl=0;
         hsb=0;
         shs=false;
         b2=false;
        }
      if(nsell(mag1)==0)
        {
         fsl=lot;
         bsl=0;
         hbb=0;
         hbl=0;
         shb=false;
         s2=false;
        }
      if(nbuy(mag1)==0 && nsell(mag1)==0)
        {
         BUY(lot,mag1,0);
         SELL(lot,mag1,0);
        }
      if(nbuy(mag1)>0 && Ask<=fbo(mag1)-dis*point)
        {
         fbl=fbl*Multiplier;
         BUY(fbl,mag1,0);
         if(nbuy(mag1)==mhl)
           {
            hsl=fbl(mag1);
            SELL(hsl,mag2,sl);
           }
         else if(nbuy(mag1)>mhl)
           {
            hsl+=fbl(mag1);
            if(hr)
               SELL(hsl-LS(mag2),mag2,sl);
            else
               SELL(fbl,mag2,sl);
           }
         if(nsell(mag1)==0)
            SELL(lot,mag1,0);
        }
      if(nsell(mag1)>0 && Bid>=fso(mag1)+dis*point)
        {
         fsl=fsl*Multiplier;
         SELL(fsl,mag1,0);
         if(nsell(mag1)==mhl)
           {
            hbl=fsl(mag1);
            BUY(hbl,mag2,sl);
           }
         else if(nsell(mag1)>mhl)
           {
            hbl+=fsl(mag1);
            if(hr)
               BUY(hbl-LB(mag2),mag2,sl);
            else
               BUY(fsl,mag2,sl);
           }
         if(nbuy(mag1)==0)
            BUY(lot,mag1,0);
        }
     }
   if(nsell(mag1)>0 && (NS(mag1)+NB(mag2)>=tp || ((NS(mag1)+NB(mag2))/(LS(mag1)+LB(mag2)))*Point>=tpp*point))
     {
      CloseSell(mag1);
      if(nbuy(mag2)>0)
         CloseBuy(mag2);
     }
   if(nbuy(mag1)>0 && (NB(mag1)+NS(mag2)>=tp || ((NB(mag1)+NS(mag2))/(LB(mag1)+LS(mag2)))*Point>=tpp*point))
     {
      CloseBuy(mag1);
      if(nsell(mag2)>0)
         CloseSell(mag2);
     }
// if((NB(mag1)+NB(mag2)+NS(mag1)+NS(mag2))<=-al)
   if(AccountProfit()<=-al)
     {
      en=false;
      if((LB(mag1)+LB(mag2))>(LS(mag1)+LS(mag2)))
         SELL((LB(mag1)+LB(mag2))-(LS(mag1)+LS(mag2)),mag2,0);
      if((LB(mag1)+LB(mag2))<(LS(mag1)+LS(mag2)))
         BUY((LS(mag1)+LS(mag2))-(LB(mag1)+LB(mag2)),mag2,0);
      ExpertRemove();
      return;
     }
   if(nbuy(mag2)>0)
     {
      for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType()==0 && OrderSymbol()==Symbol() && OrderMagicNumber()==mag2)
              {
               if(OrderStopLoss()<Bid-tsl*point && Bid-OrderOpenPrice()>=tsl*point)
                 {
                  bool mb=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-tsl*point,OrderTakeProfit(),0,clrNONE);
                  if(mb)
                    {
                     hbb=Bid-tsl*point;
                    }
                 }
              }
           }
        }
     }
   if(nsell(mag2)>0)
     {
      for(int j=0;j<OrdersTotal();j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType()==1 && OrderSymbol()==Symbol() && OrderMagicNumber()==mag2)
              {
               if((OrderStopLoss()>Ask+tsl*point || OrderStopLoss()==0) && (OrderOpenPrice()-Ask>=tsl*point))
                 {
                  bool sb=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+tsl*point,OrderTakeProfit(),0,clrNONE);
                  if(sb)
                    {
                     hsb=Ask+tsl*point;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool TradeTime()
  {
   bool result=false;

   datetime svt = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + StartTime);
   datetime bvt = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + StopTime);

   if(svt<bvt)
     {
      if(TimeCurrent()>=svt && TimeCurrent()<bvt) result=true;
     }
   else
     {
      if(TimeCurrent()>=svt || TimeCurrent()<bvt) result=true;
     }

   return(result);
  }
//+------------------------------------------------------------------+
int nbuy(int m)
  {
   int buy=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int sb=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==0 && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
         buy++;
     }
   return buy;

  }
//+------------------------------------------------------------------+
int nsell(int m)
  {
   int sel=0;
   for(int x=0;x<OrdersTotal();x++)
     {
      int ss=OrderSelect(x,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==1 && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
         sel++;

     }
   return sel;

  }
//+---------------------------------------------------------------------+
double fbo(int m)
  {
   double z=0,zz=0;
   for(int i=OrdersTotal();i>=0;i--)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
        {
         z=OrderOpenPrice();
         if(z<zz || zz==0)zz=z;
        }
     }
   return zz;
  }
//+------------------------------------------------------------------+
double fso(int m)
  {
   double z=0,zz=0;
   for(int i=OrdersTotal();i>=0;i--)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
        {
         z=OrderOpenPrice();
        }
      if(z>zz || zz==0)zz=z;
     }
   return zz;
  }
//+------------------------------------------------------------------+
double fbl(int m)
  {
   double z=0,zz=0;
   for(int i=OrdersTotal();i>=0;i--)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
        {
         z=OrderLots();
         if(z>=zz || zz==0)zz=z;
        }
     }
   return zz;
  }
//+------------------------------------------------------------------+
double fsl(int m)
  {
   double z=0,zz=0;
   for(int i=OrdersTotal();i>=0;i--)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==m)
        {
         z=OrderLots();
        }
      if(z>=zz || zz==0)zz=z;
     }
   return zz;
  }
//+------------------------------------------------------------------+
void SELL(double ll,int m,double ssl)
  {
   if(ssl>0)
     {
      ssl=Bid+ssl*point;
      if(shs)
         hsb=ssl;
     }
   if(ll>maxlot1 && en && m==mag1)
      ll=maxlot1;
   else if(ll>maxlot2 && en && m==mag2)
      ll=maxlot2;
   int sell=OrderSend(Symbol(),OP_SELL,ll,Bid,0,ssl,0,EA_Name,m,0,clrNONE);
   if(sell<0)
     {
      Print("sell failed with error #",GetLastError());
     }
   else
     {
      Print("sell placed successfully ",m);
     }
  }
////////////////////////////////////////
void BUY(double ll,int m,double ssl)
  {
   if(ssl>0)
     {
      ssl=Ask-ssl*point;
      if(shb)
         hbb=ssl;
     }
   if(ll>maxlot1 && en && m==mag1)
      ll=maxlot1;
   else if(ll>maxlot2 && en && m==mag2)
      ll=maxlot2;
   int buy=OrderSend(Symbol(),OP_BUY,ll,Ask,0,ssl,0,EA_Name,m,clrNONE);
   if(buy<0)
     {
      Print("buy failed with error #",GetLastError());
     }
   else
     {
      Print("buy placed successfully ",m);
     }
  }
//+------------------------------------------------------------------+
void CloseBuy(int m)
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         if(OrderType()==OP_BUY && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            int u=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),100,clrNONE);
           }
        }
     }
   if(nbuy(m)>0)CloseBuy(m);
  }
////////////////////////////////////////   
void CloseSell(int m)
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      int a=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         if(OrderType()==OP_SELL && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            int u=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),100,clrNONE);
           }
        }
     }
   if(nsell(m)>0)CloseSell(m);
  }
////////////////////////////////////////
double NB(int m)
  {
   double tb=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      double nb=0;
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderType()==OP_BUY && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            nb=OrderProfit();
            tb=nb+tb;
           }
        }
     }
   return tb;
  }
////////////////////////////////////////
double NS(int m)
  {
   double ts1=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      double ns=0;
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderType()==OP_SELL && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            ns=OrderProfit();
            ts1=ns+ts1;
           }
        }
     }
   return ts1;
  }
////////////////////////////////////////
double LB(int m)
  {
   double tb=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      double nb=0;
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderType()==OP_BUY && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            nb=OrderLots();
            tb=nb+tb;
           }
        }
     }
   return tb;
  }
////////////////////////////////////////
double LS(int m)
  {
   double ts1=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      double ns=0;
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderType()==OP_SELL && OrderMagicNumber()==m && OrderSymbol()==Symbol())
           {
            ns=OrderLots();
            ts1=ns+ts1;
           }
        }
     }
   return ts1;
  }
////////////////////////////////////////
