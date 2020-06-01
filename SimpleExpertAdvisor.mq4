//+------------------------------------------------------------------+
//|                                          SimpleExpertAdvisor.mq4 |
//|                                                            Indra |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Indra"
#property link      ""
#property version   "1.00"
#property strict

// External variables
extern double LotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;

extern int Slippage = 5;
extern int MagicNumber = 123;

extern int FastMAPeriode = 10;
extern int SlowMAPeriode = 20;

// Global variables
int BuyTicket;
int SellTicket;
int UseSplippage;

double UsePoint;

double BuyStopLoss;
double BuyTakeProfit;
double SellStopLoss;
double SellTakeProfit;

bool Closed;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   UsePoint = PipPoint(Symbol());
   UseSplippage = GetSlippage(Symbol(), Slippage);
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
   // Moving averages
   double FastMA = iMA(NULL, 0, FastMAPeriode, 0, 0, 0, 0);
   double SlowMA = iMA(NULL, 0, SlowMAPeriode, 0, 0, 0, 0);
   
   // Init variable
   double ClosePrice;
   double CloseLots;
   double OpenPrice;
      
   // Buy order
   if (FastMA > SlowMA && BuyTicket == 0)
   {
      bool Selected = OrderSelect(SellTicket, SELECT_BY_TICKET);
      
      if (Selected == true)
      {
         // Close order
         if (OrderCloseTime() == 0 && SellTicket > 0)
         {
            CloseLots = OrderLots();
            ClosePrice = Ask;
            
            Closed = OrderClose(SellTicket, CloseLots, ClosePrice, UseSplippage, Red);
         }
         
         OpenPrice = Ask;
         
         // Calculate stop loss and take profit
         if (StopLoss > 0) 
         {
            BuyStopLoss = OpenPrice - (StopLoss * UsePoint);
         }
         
         if (TakeProfit > 0)
         {
            BuyTakeProfit = OpenPrice + (TakeProfit * UsePoint);
         }
         
         // Open buy order
         BuyTicket = OrderSend(Symbol(), OP_BUY, LotSize, OpenPrice, UseSplippage, BuyStopLoss, BuyTakeProfit, "Buy Order", MagicNumber, 0, Green);
         
         SellTicket = 0;
      }
   }
   
   // Sell order
   if (FastMA < SlowMA && SellTicket == 0)
   {
      bool Selected = OrderSelect(BuyTicket, SELECT_BY_TICKET);
      
      if (Selected == true)
      {
         if (OrderCloseTime() == 0 && BuyTicket > 0)
         {
            CloseLots = OrderLots();
            ClosePrice = Bid;
            
            Closed = OrderClose(BuyTicket, CloseLots, ClosePrice, UseSplippage, Red);
         }
         
         OpenPrice = Bid;
         
         if (StopLoss > 0) 
         {
            SellStopLoss = OpenPrice + (StopLoss * UsePoint);
         }
         
         if (TakeProfit > 0)
         {
            SellTakeProfit = OpenPrice - (TakeProfit * UsePoint);
         }
         
         // Open sell order
         SellTicket = OrderSend(Symbol(), OP_SELL, LotSize, OpenPrice, UseSplippage, SellStopLoss, SellTakeProfit, "Sell order", MagicNumber, 0, Red);
      
         BuyTicket = 0;
      }
      
   }
   
   return (0);

}


// Pip Point Function
double PipPoint(string Currency)
{
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   
   double CalcPoint = 0;
   
   if (CalcDigits == 2 || CalcDigits == 3)
   {
      CalcPoint = 0.01;
   } else if (CalcDigits == 4 || CalcDigits == 5) {
      CalcPoint = 0.0001;
   }
   
   return (CalcPoint);
}

// Get Slippage Function
int GetSlippage(string Currency, int SP)
{
   
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   // declare
   double ClacSlippage = 0;
   
   if (CalcDigits == 2 || CalcDigits == 4) 
   {
      ClacSlippage = SP;
   } else if (CalcDigits == 3 || CalcDigits == 5) {
      ClacSlippage = SP * 10;   
   }
   
   return(ClacSlippage);
}