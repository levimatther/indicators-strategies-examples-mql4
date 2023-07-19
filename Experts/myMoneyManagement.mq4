//+------------------------------------------------------------------+
//|                                          My Money Management.mq4 |
//|                                 Ryan Sheehy, CurrencySecrets.com |
//|                                   http://www.currencysecrets.com |
//+------------------------------------------------------------------+
#property copyright "Ryan Sheehy, CurrencySecrets.com"
#property link      "http://www.currencysecrets.com"

//--- input parameters
extern double    xRiskPerTrade=1; // $ amount of risked per trade
extern int       xTimeFrame=PERIOD_H4;
extern double    xSlip=5; // max slip allowed for orders
datetime now;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   // 1. Check if there are pending OPEN orders that have been manually placed
   // 2. Amend the manually placed orders to display the correct position size
   // amount for their trades
   // 3. Flag newly placed order with correct position size as a non-manually
   // placed trade.
   bool flag;
   for ( int i = 0; i < OrdersTotal(); i++ ) {
      if ( OrderSelect(i, SELECT_BY_POS, MODE_TRADES) ) {
         // the assumption will be that new manual orders have a MagicNumber of 0
         if ( OrderMagicNumber() == 0 && OrderCloseTime() == 0 ) {
            // find the Limit & Stop pending orders
            if ( OrderType() != OP_BUY || OrderType() != OP_SELL ) {
               if ( reorder(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderTakeProfit(), OrderType()) > 0 ) {
                 // remove current order as new ticket has been issued
                  OrderDelete(OrderTicket());
               }
            } 
         }
         // if there is a closer swing point we need to reposition our trade
         // we only want to do this when there has been a change of bar
         flag = false;
         if ( OrderMagicNumber() == 1 && OrderCloseTime() == 0 && now != iTime(OrderSymbol(), xTimeFrame, 0) ) {
            now = iTime(OrderSymbol(), xTimeFrame, 0);
            if ( OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP ) {
               if ( getStopLoss(OrderSymbol(),OrderType(),OrderOpenPrice()) > OrderStopLoss() ) {
                  flag = true;
               } 
            } else if ( OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP ) {
               if ( getStopLoss(OrderSymbol(), OrderType(), OrderOpenPrice()) < OrderStopLoss() ) {
                  flag = true;
               }
            }
            if ( flag ) {
               if ( reorder(OrderSymbol(), OrderOpenPrice(), 0, OrderTakeProfit(), OrderType()) > 0 ) {
                  OrderDelete(OrderTicket());
               }
            }
         }
      }   
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

/*
 * Check orders placed and apply better risk management by checking qty ordered
 * and stop loss placed
 * @param sym  string Symbol of currency
 * @param entry double Entry price of order
 * @param stop double Stop loss of order 
 * @param tp double Target Profit of order 
 * @param ord int OrderType() = OP_BUYLIMIT, OP_BUYSTOP, OP_SELLLIMIT, OP_SELLSTOP
 * @return int Ticket number of newly placed order 
 */
int reorder(string sym, double entry, double stop, double tp, int ord) {
   // check if order already has an attached stop loss, if not get one!
   if ( stop == 0 ) {
      stop = getStopLoss(sym, ord, entry);
   }
   // calculate position size
   double qty = calcPositionSize(sym, entry, stop);
   // insert new order
   return( OrderSend(sym, ord, qty, entry, xSlip, stop, tp, 0, 1, 0) );  
}

/*
 * Calculates the position size of the trade based upon entry price and stop
 * loss and amount to risk.
 * @param sym  string   Symbol of currency
 * @param entry double  Entry price of the order 
 * @param stop double   Stop loss of the order 
 * @return     double   Quantity of order 
 */
double calcPositionSize(string sym, double entry, double stop) {
   double dist = MathAbs( entry - stop ) + (MarketInfo(sym, MODE_SPREAD) * MarketInfo(sym, MODE_POINT));
   int dec = MathLog(1 / MarketInfo( Symbol(), MODE_LOTSTEP )) / MathLog(10);
   double qty = NormalizeDouble((xRiskPerTrade / dist) * MarketInfo(sym, MODE_POINT), dec);
   return( qty );
}

/*
 * Get the price of the Stop Loss according to last swing price.
 * @param sym  string   Symbol of currency being analysed
 * @param ord  int      OrderType() = OP_BUYLIMIT, OP_BUYSTOP, OP_SELLLIMIT, OP_SELLSTOP
 * @param entry double  Entry price of the order 
 * @return      double   Last swing point 
 */
double getStopLoss(string sym, int ord, double entry) {
   int bars = iBars(sym, xTimeFrame);
   double stop;
   int dir;
   if ( ord == OP_BUYLIMIT || ord == OP_BUYSTOP ) {
      dir = 1;
   } else if ( ord == OP_SELLLIMIT || ord == OP_SELLSTOP ) {
      dir = -1;
   }
   // do NOT use 0 as the current bar is still evolving!
   for ( int i = 1; i < bars; i++ ) {
      if ( dir == -1 && iHigh(sym, xTimeFrame, i) < iHigh(sym, xTimeFrame, i+1) &&
      iHigh(sym, xTimeFrame, i+1) >= iHigh(sym, xTimeFrame, i+2) && 
      iHigh(sym, xTimeFrame, i+1) > entry ) {
         stop = iHigh(sym, xTimeFrame, i+1);
         break;
      }
      if ( dir == 1 && iLow(sym, xTimeFrame, i) > iLow(sym, xTimeFrame, i+1) &&
      iLow(sym, xTimeFrame, i+1) <= iLow(sym, xTimeFrame, i+2) &&
      iLow(sym, xTimeFrame, i+1) < entry ) {
         stop = iLow(sym, xTimeFrame, i+1);
         break;
      }
   }
   return ( stop ); 
}