//+------------------------------------------------------------------+
//|                                                       my_RSI.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  20131111

//--Time Limitation
input int      RSIPer                                 = 13;
input ENUM_APPLIED_PRICE RSI_Price                    = PRICE_CLOSE;             //RSI_Price


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
//| initializing...                                                  |
//+------------------------------------------------------------------+
 void OnTick(){   
 
   
   //double val = iCustom(Symbol(),0,"jack_indicator",2,0,0);
   double val = iCustom(NULL,0,"jack_indicator",2,1,1);
   Print("Custom Value : ",val);
   
   double RSI0  = iRSI(NULL,0,RSIPer,RSI_Price,0);
   double RSI1  = iRSI(NULL,0,RSIPer,RSI_Price,1);   
   
   if (RSI0 > 30 && RSI1 < 30) {
      Print("Buy : ");
   } 
   if (RSI0 < 70 && RSI1 > 70) {
      Print("Sell : ");
   }
   
    double spread = MarketInfo(Symbol(), MODE_SPREAD);

    // Showing a message box with the values.
    MessageBox("Spread = " + spread);
   
}
