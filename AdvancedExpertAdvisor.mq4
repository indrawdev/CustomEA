//+------------------------------------------------------------------+
//|                                        AdvancedExpertAdvisor.mq4 |
//|                                                            Indra |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Indra"
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

// External variables
extern bool DynamicLotSize = true;
extern double EquityPercent = 2;
extern double FixedLotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;
extern int Slippage = 5;
extern int MagicNumber = 123;
extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;

// Global variables
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

int start()
{
   // Moving averages
   double FastMA = iMA(NULL, 0, FastMAPeriod, 0, 0, 0, 1);
   double SlowMA = iMA(NULL, 0, SlowMAPeriod, 0, 0, 0, 1);
   
   // Lot size calculation
   if (DynamicLotSize == true)
   {
      double RiskAmount = AccountEquity() * (EquityPercent / 100);
      double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
      
      if (Point == 0.001 || Point == 0.00001)
      {
         TickValue = TickValue * 10;
      }
      
      double CalcLots = (RiskAmount / StopLoss) / TickValue;
      double LotSize = CalcLots;
   } 
   else 
   {
      double LotSize = FixedLotSize;
   }
   
   // Lot size verification
   if (LotSize < MarketInfo(Symbol(), MODE_MINLOT))
   {
      LotSize = MarketInfo(Symbol(), MODE_MINLOT);
   }
   else if (LotSize > MarketInfo(Symbol(), MODE_MAXLOT))
   {
      LotSize = MarketInfo(Symbol(), MODE_MAXLOT);
   }
   
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1)
   {
      LotSize = NormalizeDouble(LotSize, 1);
   }
   else 
   {
      LotSize = NormalizeDouble(LotSize, 2);
   }
   
   // Buy Order
   if (FastMA > SlowMA && BuyTicket == 0)
   {
      // Close order
      if (OrderSelect(SellTicket, SELECT_BY_TICKET)== true)
      {
         if (OrderCloseTime() == 0 && SellTicket > 0)
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
               string ErrDesc = ErrorDescription(ErrorCode);
               string ErrAlert = StringConcatenate("Close Sell Order - Error ", ErrorCode, ": ", ErrDesc);
               Alert(ErrAlert);
               
               string ErrLog = StringConcatenate("Ask: ", Ask," Lots: ", LotSize, " Ticket: ", SellTicket);
               Print(ErrLog);
            }
         }
         
         // Open buy order
         while(IsTradeContextBusy()) Sleep(10);
         RefreshRates();
         
         BuyTicket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, UseSlippage, 0, 0, "Buy Order", MagicNumber, 0, Green);
         
         // Error handling
         if (BuyTicket == -1)
         {
            ErrorCode = GetLastError();
            ErrDesc = ErrorDescription(ErrorCode);
            
            ErrAlert = StringConcatenate("Open Buy Order - Error ", ErrorCode, ": ", ErrDesc);
            Alert(ErrAlert);
            
            ErrLog = StringConcatenate("Ask: ", Ask, " Lots: ", LotSize);
            Print(ErrLog);
         }
         // Order modification
         else 
         {
            OrderSelect(BuyTicket, SELECT_BY_TICKET);
            
         }
      }
   }
}
