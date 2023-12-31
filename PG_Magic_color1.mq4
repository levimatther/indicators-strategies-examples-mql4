//+------------------------------------------------------------------+
//|                                              PG_Magic_Color1.mq4 |
//|                                      Copyright 2023 pg-magic.com |
//|                                         https://www.pg-magic.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2023, PG-Magic"
#property link      "E-mail:pgmagic@pg-magic.com"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 RoyalBlue // wicks
#property indicator_color2 Red       // wicks
#property indicator_color3 RoyalBlue // Candle Bodies
#property indicator_color4 Red       // Candle Bodies

extern int Candle_MA_Period   = 34;
extern int Candle_MA_Shift    = 0;
extern int Candle_Type        = 1;
extern int Candle_MA_Price    = 0;
extern int Candle_Shadow_Width = 1;
extern int Candle_Body_Width   = 3;
extern string Type_Key         = "0: SMA, 1: EMA, 2: SMMA, 3: LWMA";
extern string Price_Key        = "0: Close, 1: Open, 2: High";
extern string Price_Key_cont   = " 3: Low, 4: Median";

extern int MA_Period = 20; // Período da média móvel
extern int MA_Mode = 0;    // Modo da média móvel (0: SMA, 1: EMA, 2: SMMA, 3: LWMA)
extern int MA_Price = 0;   // Preço utilizado para o cálculo da média móvel (0: Close, 1: Open, 2: High, 3: Low, 4: Median)

extern color Text_Color = clrWhite;      // Cor do texto
extern int Text_Size = 12;                // Tamanho da fonte do texto
extern int Text_OffsetX = 10;             // Deslocamento horizontal do texto em relação à borda esquerda
extern int Text_OffsetY = 10;             // Deslocamento vertical do texto em relação à borda inferior

int MA1       = 1;
int MA1_MODE  = 0;
int MA1_PRICE = 0;
int MA1_SHIFT = 0;

double Bar1[];
double Bar2[];
double Candle1[];
double Candle2[];

void DrawTextOnChart(string text, int fontSize, color textColor, int offsetX, int offsetY)
{
   int textWidth = StringLen(text) * fontSize / 2;
   int textHeight = fontSize;

   int chartWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartHeight = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   int x = chartWidth - textWidth - offsetX;
   int y = chartHeight - textHeight - offsetY;

   ObjectCreate(0, "Text", OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, "Text", OBJPROP_TEXT, text);
   ObjectSetInteger(0, "Text", OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, "Text", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "Text", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "Text", OBJPROP_FONTSIZE, fontSize);
}

bool IsTrialExpired()
{
   datetime expiration_date = StrToTime("06.06.2023 00:00:00"); // Data de expiração da versão de avaliação

   return TimeCurrent() > expiration_date;
}

int init()
{
   IndicatorShortName("PG_Magic");
   IndicatorBuffers(4);
   
   SetIndexBuffer(0, Bar1);
   SetIndexBuffer(1, Bar2);
   SetIndexBuffer(2, Candle1);
   SetIndexBuffer(3, Candle2);
   
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, Candle_Shadow_Width);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, Candle_Shadow_Width);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0, Candle_Body_Width);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0, Candle_Body_Width);
   
   SetIndexLabel(0, "R up L, R dn L, B up H, B dn H");
   SetIndexLabel(1, "R up H, R dn H, B up L, B dn L");
   SetIndexLabel(2, "R up O, R dn C, B up C, B dn O");
   SetIndexLabel(3, "R up C, R dn O, B up O, B dn C");

   return 0;
}

double MA_1(int i = 0)
{
   return iMA(NULL, 0, MA1, MA1_SHIFT, MA1_MODE, MA1_PRICE, i);
}

double MA_2(int i = 0)
{
   return iMA(NULL, 0, Candle_MA_Period, Candle_MA_Shift, Candle_Type, Candle_MA_Price, i);
}

void SetCandleColor(int col, int i)
{
   double high, low, bodyHigh, bodyLow;

   bodyHigh = MathMax(Open[i], Close[i]);
   bodyLow = MathMin(Open[i], Close[i]);
   high = High[i];
   low = Low[i];

   switch (col)
   {
      case 1:
         Bar1[i] = high;
         Bar2[i] = low;
         Candle1[i] = bodyHigh;
         Candle2[i] = bodyLow;
         break;
      case 2:
         Bar2[i] = high;
         Bar1[i] = low;
         Candle2[i] = bodyHigh;
         Candle1[i] = bodyLow;
         break;
   }
}

string GetTimeframeString(int timeframe)
{
   string timeframeString;

   switch (timeframe)
   {
      case PERIOD_M1:
         timeframeString = "1 Minute";
         break;
      case PERIOD_M5:
         timeframeString = "5 Minutes";
         break;
      case PERIOD_M15:
         timeframeString = "15 Minutes";
         break;
      case PERIOD_M30:
         timeframeString = "30 Minutes";
         break;
      case PERIOD_H1:
         timeframeString = "1 Hour";
         break;
      case PERIOD_H4:
         timeframeString = "4 Hours";
         break;
      case PERIOD_D1:
         timeframeString = "1 Day";
         break;
      case PERIOD_W1:
         timeframeString = "1 Week";
         break;
      case PERIOD_MN1:
         timeframeString = "1 Month";
         break;
      default:
         timeframeString = "Unknown";
         break;
   }

   return timeframeString;
}

int start()
{
   static int prevColor = 0;

   for (int i = MathMax(Bars - 1 - IndicatorCounted(), 1); i >= 0; i--)
   {
   double Ma1 = MA_1(i);
      double Ma2 = MA_2(i);
      double maValue = iMA(NULL, 0, MA_Period, 0, MA_Mode, MA_Price, i);

      int currentColor = 0;

      if (Ma1 > maValue && Ma2 > maValue)
      {
         SetCandleColor(1, i);
         currentColor = 1;
      }
      else if (Ma1 < maValue && Ma2 < maValue)
      {
         SetCandleColor(2, i);
         currentColor = 2;
      }

      if (currentColor != prevColor)
      {
         string colorText = (currentColor == 1) ? "Bullish" : "Bearish";
         DrawTextOnChart("PG_Magic_2023 - Current Color: " + colorText, Text_Size, Text_Color, Text_OffsetX, Text_OffsetY);
         prevColor = currentColor;
      }
   }

   return 0;
}

