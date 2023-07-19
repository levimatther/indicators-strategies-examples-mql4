//+------------------------------------------------------------------+
//|                                                     [EXPORT].mq4 |
//|                                          Copyright © 2009, Ra457 |
//|                                                ra457fx@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2009 Ra457"
#property link      "ra457fx@gmail.com"


int start()
  {
 static int  flag;
 int handle;

	
//=========================================================== 
  double EURUSD_OPEN, EURUSD_CLOSE, EURUSD_HIGH, EURUSD_LOW, EURUSD_Volume;
         
         EURUSD_OPEN = iOpen("EURUSD",PERIOD_D1,1);
         EURUSD_CLOSE =  iClose("EURUSD",PERIOD_D1,1);
         EURUSD_HIGH =  iHigh("EURUSD",PERIOD_D1,1);
         EURUSD_LOW =  iLow("EURUSD",PERIOD_D1,1);
         EURUSD_Volume =  iVolume("EURUSD",PERIOD_D1,1);
//=========================================================== 
  double GBPUSD_OPEN, GBPUSD_CLOSE, GBPUSD_HIGH, GBPUSD_LOW, GBPUSD_Volume;
         
         GBPUSD_OPEN = iOpen("GBPUSD",PERIOD_D1,1);
         GBPUSD_CLOSE =  iClose("GBPUSD",PERIOD_D1,1);
         GBPUSD_HIGH =  iHigh("GBPUSD",PERIOD_D1,1);
         GBPUSD_LOW =  iLow("GBPUSD",PERIOD_D1,1);
         GBPUSD_Volume =  iVolume("GBPUSD",PERIOD_D1,1);
//=========================================================== 
  double USDCHF_OPEN, USDCHF_CLOSE, USDCHF_HIGH, USDCHF_LOW, USDCHF_Volume;
         
         USDCHF_OPEN = iOpen("USDCHF",PERIOD_D1,1);
         USDCHF_CLOSE =  iClose("USDCHF",PERIOD_D1,1);
         USDCHF_HIGH =  iHigh("USDCHF",PERIOD_D1,1);
         USDCHF_LOW =  iLow("USDCHF",PERIOD_D1,1);
         USDCHF_Volume =  iVolume("USDCHF",PERIOD_D1,1);
//=========================================================== 
  double GBPCHF_OPEN, GBPCHF_CLOSE, GBPCHF_HIGH, GBPCHF_LOW, GBPCHF_Volume;
         
         GBPCHF_OPEN = iOpen("GBPCHF",PERIOD_D1,1);
         GBPCHF_CLOSE =  iClose("GBPCHF",PERIOD_D1,1);
         GBPCHF_HIGH =  iHigh("GBPCHF",PERIOD_D1,1);
         GBPCHF_LOW =  iLow("GBPCHF",PERIOD_D1,1);
         GBPCHF_Volume =  iVolume("GBPCHF",PERIOD_D1,1);
         //=========================================================== 
  double EURCHF_OPEN, EURCHF_CLOSE, EURCHF_HIGH, EURCHF_LOW, EURCHF_Volume;
         
         EURCHF_OPEN = iOpen("EURCHF",PERIOD_D1,1);
         EURCHF_CLOSE =  iClose("EURCHF",PERIOD_D1,1);
         EURCHF_HIGH =  iHigh("EURCHF",PERIOD_D1,1);
         EURCHF_LOW =  iLow("EURCHF",PERIOD_D1,1);
         EURCHF_Volume =  iVolume("EURCHF",PERIOD_D1,1);
//=========================================================== 
  double USDJPY_OPEN, USDJPY_CLOSE, USDJPY_HIGH, USDJPY_LOW, USDJPY_Volume;
         
         USDJPY_OPEN = iOpen("USDJPY",PERIOD_D1,1);
         USDJPY_CLOSE =  iClose("USDJPY",PERIOD_D1,1);
         USDJPY_HIGH =  iHigh("USDJPY",PERIOD_D1,1);
         USDJPY_LOW =  iLow("USDJPY",PERIOD_D1,1);
         USDJPY_Volume =  iVolume("USDJPY",PERIOD_D1,1);
//=========================================================== 
  double GBPJPY_OPEN, GBPJPY_CLOSE, GBPJPY_HIGH, GBPJPY_LOW, GBPJPY_Volume;
         
         GBPJPY_OPEN = iOpen("GBPJPY",PERIOD_D1,1);
         GBPJPY_CLOSE =  iClose("GBPJPY",PERIOD_D1,1);
         GBPJPY_HIGH =  iHigh("GBPJPY",PERIOD_D1,1);
         GBPJPY_LOW =  iLow("GBPJPY",PERIOD_D1,1);
         GBPJPY_Volume =  iVolume("GBPJPY",PERIOD_D1,1);
//=========================================================== 
  double EURJPY_OPEN, EURJPY_CLOSE, EURJPY_HIGH, EURJPY_LOW, EURJPY_Volume;
         
         EURJPY_OPEN = iOpen("EURJPY",PERIOD_D1,1);
         EURJPY_CLOSE =  iClose("EURJPY",PERIOD_D1,1);
         EURJPY_HIGH =  iHigh("EURJPY",PERIOD_D1,1);
         EURJPY_LOW =  iLow("EURJPY",PERIOD_D1,1);
         EURJPY_Volume =  iVolume("EURJPY",PERIOD_D1,1);
//=========================================================== 
  double AUDJPY_OPEN, AUDJPY_CLOSE, AUDJPY_HIGH, AUDJPY_LOW, AUDJPY_Volume;
         
         AUDJPY_OPEN = iOpen("AUDJPY",PERIOD_D1,1);
         AUDJPY_CLOSE =  iClose("AUDJPY",PERIOD_D1,1);
         AUDJPY_HIGH =  iHigh("AUDJPY",PERIOD_D1,1);
         AUDJPY_LOW =  iLow("AUDJPY",PERIOD_D1,1);
         AUDJPY_Volume =  iVolume("AUDJPY",PERIOD_D1,1);
//=========================================================== 
  double NZDJPY_OPEN, NZDJPY_CLOSE, NZDJPY_HIGH, NZDJPY_LOW, NZDJPY_Volume;
         
         NZDJPY_OPEN = iOpen("NZDJPY",PERIOD_D1,1);
         NZDJPY_CLOSE =  iClose("NZDJPY",PERIOD_D1,1);
         NZDJPY_HIGH =  iHigh("NZDJPY",PERIOD_D1,1);
         NZDJPY_LOW =  iLow("NZDJPY",PERIOD_D1,1);
         NZDJPY_Volume =  iVolume("NZDJPY",PERIOD_D1,1);
//=========================================================== 
  double CHFJPY_OPEN, CHFJPY_CLOSE, CHFJPY_HIGH, CHFJPY_LOW, CHFJPY_Volume;
         
         CHFJPY_OPEN = iOpen("CHFJPY",PERIOD_D1,1);
         CHFJPY_CLOSE =  iClose("CHFJPY",PERIOD_D1,1);
         CHFJPY_HIGH =  iHigh("CHFJPY",PERIOD_D1,1);
         CHFJPY_LOW =  iLow("CHFJPY",PERIOD_D1,1);
         CHFJPY_Volume =  iVolume("CHFJPY",PERIOD_D1,1);
//=========================================================== 
  double USDCAD_OPEN, USDCAD_CLOSE, USDCAD_HIGH, USDCAD_LOW, USDCAD_Volume;
         
         USDCAD_OPEN = iOpen("USDCAD",PERIOD_D1,1);
         USDCAD_CLOSE =  iClose("USDCAD",PERIOD_D1,1);
         USDCAD_HIGH =  iHigh("USDCAD",PERIOD_D1,1);
         USDCAD_LOW =  iLow("USDCAD",PERIOD_D1,1);
         USDCAD_Volume =  iVolume("USDCAD",PERIOD_D1,1);
//=========================================================== 
  double AUDUSD_OPEN, AUDUSD_CLOSE, AUDUSD_HIGH, AUDUSD_LOW, AUDUSD_Volume;
         
         AUDUSD_OPEN = iOpen("AUDUSD",PERIOD_D1,1);
         AUDUSD_CLOSE =  iClose("AUDUSD",PERIOD_D1,1);
         AUDUSD_HIGH =  iHigh("AUDUSD",PERIOD_D1,1);
         AUDUSD_LOW =  iLow("AUDUSD",PERIOD_D1,1);
         AUDUSD_Volume =  iVolume("AUDUSD",PERIOD_D1,1);
//=========================================================== 
  double NZDUSD_OPEN, NZDUSD_CLOSE, NZDUSD_HIGH, NZDUSD_LOW, NZDUSD_Volume;
         
         NZDUSD_OPEN = iOpen("NZDUSD",PERIOD_D1,1);
         NZDUSD_CLOSE =  iClose("NZDUSD",PERIOD_D1,1);
         NZDUSD_HIGH =  iHigh("NZDUSD",PERIOD_D1,1);
         NZDUSD_LOW =  iLow("NZDUSD",PERIOD_D1,1);
         NZDUSD_Volume =  iVolume("NZDUSD",PERIOD_D1,1);
//=========================================================== 
  double EURGBP_OPEN, EURGBP_CLOSE, EURGBP_HIGH, EURGBP_LOW, EURGBP_Volume;
         
         EURGBP_OPEN = iOpen("EURGBP",PERIOD_D1,1);
         EURGBP_CLOSE =  iClose("EURGBP",PERIOD_D1,1);
         EURGBP_HIGH =  iHigh("EURGBP",PERIOD_D1,1);
         EURGBP_LOW =  iLow("EURGBP",PERIOD_D1,1);
         EURGBP_Volume =  iVolume("EURGBP",PERIOD_D1,1);
//=========================================================== 

         
         
 handle=FileOpen("Daily_Base.csv", FILE_CSV|FILE_WRITE, ',');
   if(handle>0)
   //FileWrite can only handle 63 parameters at a time. The first 60 are in one FileWrite command, the rest are in the second.  
   //When imported into a spreadsheet, each new FileWrite command will generate a new row. 
    {
     FileWrite(handle, 
     DoubleToStr(EURUSD_OPEN,4), DoubleToStr(EURUSD_CLOSE,4), DoubleToStr(EURUSD_HIGH,4), DoubleToStr(EURUSD_LOW,4), DoubleToStr(EURUSD_Volume,4),
     DoubleToStr(GBPUSD_OPEN,4), DoubleToStr(GBPUSD_CLOSE,4), DoubleToStr(GBPUSD_HIGH,4), DoubleToStr(GBPUSD_LOW,4), DoubleToStr(GBPUSD_Volume,4),
     DoubleToStr(USDCHF_OPEN,4), DoubleToStr(USDCHF_CLOSE,4), DoubleToStr(USDCHF_HIGH,4), DoubleToStr(USDCHF_LOW,4), DoubleToStr(USDCHF_Volume,4),
     DoubleToStr(GBPCHF_OPEN,4), DoubleToStr(GBPCHF_CLOSE,4), DoubleToStr(GBPCHF_HIGH,4), DoubleToStr(GBPCHF_LOW,4), DoubleToStr(GBPCHF_Volume,4),
     DoubleToStr(EURCHF_OPEN,4), DoubleToStr(EURCHF_CLOSE,4), DoubleToStr(EURCHF_HIGH,4), DoubleToStr(EURCHF_LOW,4), DoubleToStr(EURCHF_Volume,4),
     DoubleToStr(USDJPY_OPEN,2), DoubleToStr(USDJPY_CLOSE,2), DoubleToStr(USDJPY_HIGH,2), DoubleToStr(USDJPY_LOW,2), DoubleToStr(USDJPY_Volume,2),
     DoubleToStr(GBPJPY_OPEN,2), DoubleToStr(GBPJPY_CLOSE,2), DoubleToStr(GBPJPY_HIGH,2), DoubleToStr(GBPJPY_LOW,2), DoubleToStr(GBPJPY_Volume,2),
     DoubleToStr(EURJPY_OPEN,2), DoubleToStr(EURJPY_CLOSE,2), DoubleToStr(EURJPY_HIGH,2), DoubleToStr(EURJPY_LOW,2), DoubleToStr(EURJPY_Volume,2),
     DoubleToStr(AUDJPY_OPEN,2), DoubleToStr(AUDJPY_CLOSE,2), DoubleToStr(AUDJPY_HIGH,2), DoubleToStr(AUDJPY_LOW,2), DoubleToStr(AUDJPY_Volume,2),
     DoubleToStr(NZDJPY_OPEN,2), DoubleToStr(NZDJPY_CLOSE,2), DoubleToStr(NZDJPY_HIGH,2), DoubleToStr(NZDJPY_LOW,2), DoubleToStr(NZDJPY_Volume,2),
     DoubleToStr(CHFJPY_OPEN,2), DoubleToStr(CHFJPY_CLOSE,2), DoubleToStr(CHFJPY_HIGH,2), DoubleToStr(CHFJPY_LOW,2), DoubleToStr(CHFJPY_Volume,2),
     DoubleToStr(USDCAD_OPEN,4), DoubleToStr(USDCAD_CLOSE,4), DoubleToStr(USDCAD_HIGH,4), DoubleToStr(USDCAD_LOW,4), DoubleToStr(USDCAD_Volume,4)
     );
     FileWrite(handle,
     DoubleToStr(AUDUSD_OPEN,4), DoubleToStr(AUDUSD_CLOSE,4), DoubleToStr(AUDUSD_HIGH,4), DoubleToStr(AUDUSD_LOW,4), DoubleToStr(AUDUSD_Volume,4),
	  DoubleToStr(NZDUSD_OPEN,4), DoubleToStr(NZDUSD_CLOSE,4), DoubleToStr(NZDUSD_HIGH,4), DoubleToStr(NZDUSD_LOW,4), DoubleToStr(NZDUSD_Volume,4),
     DoubleToStr(EURGBP_OPEN,4), DoubleToStr(EURGBP_CLOSE,4), DoubleToStr(EURGBP_HIGH,4), DoubleToStr(EURGBP_LOW,4), DoubleToStr(EURGBP_Volume,4)
     );
     FileClose(handle);
     Comment(" D1 Exported ");
    }

    return(0);
  
}        