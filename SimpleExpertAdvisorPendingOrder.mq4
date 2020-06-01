//+------------------------------------------------------------------+
//|                              SimpleExpertAdvisorPendingOrder.mq4 |
//|                                                            Indra |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Indra"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// External variables
extern double LotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;
extern int PendingPips = 10;

extern int Slippage = 5;
extern int MagicNumber = 123;

extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;

// Global variables
int BuyTicket;
int SellTicket;

double UsePoint;
int UseSlippage;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   UsePoint = PipPoint(Symbol());
   UseSlippage = GetSlippage(Symbol(), Slippage);
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
      start();
  }
//+------------------------------------------------------------------+


int start()
{

   // Declare variables
   double CloseLots;
   double ClosePrice;
   
   
   // Moving averages
   double FastMA = iMA(NULL, 0, FastMAPeriod, 0, 0, 0, 0);
   double SlowMA = iMA(NULL, 0, SlowMAPeriod, 0, 0, 0, 0);
   
   // Buy order 
   if (FastMA > SlowMA && BuyTicket == 0)
   {
      // Declare variables
      double BuyStopLoss = 0;
      double BuyTakeProfit = 0;
      
      if (OrderSelect(SellTicket, SELECT_BY_TICKET, MODE_TRADES)== true)
      {
         
         // Close order
         if (OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELL)
         {
            CloseLots = OrderLots();
            ClosePrice = Ask;
            
            bool Closed = OrderClose(SellTicket, CloseLots, ClosePrice, UseSlippage, Red);
         } 
         // Delete order
         else if (OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELLSTOP)
         {
            bool Deleted = OrderDelete(SellTicket, Red);
         }
         
         double PendingPrice = High[0] + (PendingPips * UsePoint);
         
         // Calculate stop loss and take profit
         if (StopLoss > 0) 
         {
            BuyStopLoss = PendingPrice - (StopLoss * UsePoint);
         }
         
         if (TakeProfit > 0)
         {
            BuyTakeProfit = PendingPrice + (TakeProfit * UsePoint);
         }
         
         // Open buy order
         BuyTicket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, PendingPrice, UseSlippage, BuyStopLoss, BuyTakeProfit, "Buy Stop Order", MagicNumber, 0, Green);
         
         SellTicket = 0;
      
      }
   }
   
   // Sell order
   if (FastMA < SlowMA && SellTicket == 0) 
   {
      // Declare variables
      double SellStopLoss = 0;
      double SellTakeProfit = 0;
      
      if (OrderSelect(BuyTicket, SELECT_BY_TICKET, MODE_TRADES) == true)
      {
         if (OrderCloseTime() == 0 && BuyTicket > 0 && OrderType() == OP_BUY)
         {
            CloseLots = OrderLots();
            ClosePrice = Bid;
            
            bool Closed = OrderClose(BuyTicket, CloseLots, ClosePrice, UseSlippage, Red);
         }
         else if (OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_BUYSTOP)
         {
            bool Deleted = OrderDelete(SellTicket, Red);
         }
         
         double PendingPrice = Low[0] - (PendingPips * UsePoint);
         
         if (StopLoss > 0)
         {
            SellStopLoss = PendingPrice + (StopLoss * UsePoint);
         }
         
         if (TakeProfit > 0)
         {
            SellTakeProfit = PendingPrice - (TakeProfit * UsePoint);
         }
         
         SellTicket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, PendingPrice, UseSlippage, SellStopLoss, SellTakeProfit, "Sell Stop Order", MagicNumber, 0, Red);
         
         BuyTicket = 0;
      }
   }
   
   return (0);

}


// Pip Point function
double PipPoint(string Currency)
{
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   
   double CalcPoint = 0;
   if (CalcDigits == 2 || CalcDigits == 3)
   {
      CalcPoint = 0.01;
   }
   else if (CalcDigits == 4 || CalcDigits == 4)
   {
      CalcPoint = 0.0001;
   }
   
   return(CalcPoint);
}

// Get Slippage function
int GetSlippage(string Currency, int SP)
{
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   double CalcSlippage = 0;
   
   if (CalcDigits == 2 || CalcDigits == 3)
   {
      CalcSlippage = SP;
   }
   else if (CalcDigits == 4 || CalcDigits == 4)
   {
      CalcSlippage = SP * 10;
   }
   
   return(CalcSlippage);
   
}