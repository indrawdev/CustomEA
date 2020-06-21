//+------------------------------------------------------------------+
//|                                       AdvancedEAPendingOrder.mq4 |
//|                                                            Indra |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Indra"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
#include <stdlib.mqh>
// EA using pending stop order

// External Variable
extern int PendingPips = 20;
extern double LotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;
extern int Slippage = 5;
extern int MagicNumber = 123;
extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;

// Global Variables
int BuyTicket;
int SellTicket;
double UsePoint;
int UseSlippage;
int ErrorCode;
 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   UsePoint = PipPoint(Symbol());
   UseSlippage = GetSlippage(Symbol(), Slippage);   
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
//---
   
  }
//+------------------------------------------------------------------+

// Start function
int start()
{
   // Moving average
   double FastMA = iMA(NULL, 0, FastMAPeriod, 0, 0, 0, 0);
   double SlowMA = iMA(NULL, 0, SlowMAPeriod, 0, 0, 0, 0);
   
   // Buy order
   if (FastMA > SlowMA && BuyTicket == 0)
   {
      // Close order
      OrderSelect(SellTicket, SELECT_BY_TICKET);
      
      if (OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELL)
      {
         double CloseLots = OrderLots();
         
         while(IsTradeContextBusy()) Sleep(10);
         RefreshRates();
         double ClosePrice = Ask;
         
         bool Closed = OrderClose(SellTicket, CloseLots, ClosePrice, UseSlippage, Red);
         
         // Error handling
         if (Closed == false)
         {
            ErrorCode = GetLastError();
            string ErrorDesc = ErrorDescription(ErrorCode);
            
            string ErrAlert = StringConcatenate("Close Sell Order - Error ", ErrorCode, ": ", ErrorDesc);
            Alert(ErrAlert);
            
            string ErrLog = StringConcatenate("Ask: ", Ask, " Lots: ", LotSize, " Ticket: ", SellTicket);
            Print(ErrLog);
         }
      }
      else if (OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELLSTOP)
      {
         bool Deleted = OrderDelete(SellTicket, Red);
         
         if (Deleted == true)
         {
            ErrorCode = GetLastError();
            string ErrorDesc = ErrorDescription(ErrorCode);
            
            string ErrAlert = StringConcatenate("Delete Sell Stop Order - Error ", ErrorCode, ": ", ErrorDesc);
            Alert(ErrAlert);
            
            string ErrLog = StringConcatenate("Ask: ", Ask, " Ticket: ", SellTicket);
            Print(ErrLog);
            
         }
      }
      
      // Calculate stop level
      double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
      RefreshRates();;
      double UpperStopLevel = Ask + StopLevel;
      double MinStop = 5 * UsePoint;
      
      // Calculate pending price
      double PendingPrice = High[0] + (PendingPips * UsePoint);
      if (PendingPrice < UpperStopLevel)
      {
         PendingPrice = UpperStopLevel + MinStop;
      }
      
      // Calculate stop loss and take profit
      UpperStopLevel = PendingPrice + StopLoss;
      
      
   }
}