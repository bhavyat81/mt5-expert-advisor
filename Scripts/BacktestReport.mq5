//+------------------------------------------------------------------+
//|                                         BacktestReport.mq5      |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright    "Copyright 2025, Ravan Trading Systems"
#property link         "https://www.mql5.com/en/users/ravan"
#property version      "1.00"
#property description  "Enhanced backtest statistics report — exports to CSV"
#property script_show_confirm    false
#property script_show_inputs     true

//-------------------------------------------------------------------
//  INPUTS
//-------------------------------------------------------------------
input string InpOutputFile = "RavanEA_BacktestReport.csv"; // Output CSV filename
input int    InpMagicNumber = 202501; // Magic number to filter (0 = all)

//-------------------------------------------------------------------
//  Script entry point
//-------------------------------------------------------------------
void OnStart()
  {
   Print("BacktestReport: Generating report...");

   // Collect closed trade history
   HistorySelect(0, TimeCurrent());
   int totalDeals = HistoryDealsTotal();

   if(totalDeals == 0)
     {
      MessageBox("No trade history found. Run a backtest first.", "Ravan Backtest Report", MB_OK | MB_ICONINFORMATION);
      return;
     }

   // --- Aggregate statistics ---
   int    wins         = 0;
   int    losses       = 0;
   int    totalTrades  = 0;
   double grossProfit  = 0.0;
   double grossLoss    = 0.0;
   double maxDD        = 0.0;
   double peakBalance  = 0.0;
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double sumProfits   = 0.0;
   double sumSqProfits = 0.0;
   double maxWin       = 0.0;
   double maxLoss      = 0.0;
   double runningBalance = 0.0;

   // We need initial balance — approximate from first deal
   bool   firstDeal    = true;
   double initialBalance = 0.0;

   for(int i = 0; i < totalDeals; i++)
     {
      ulong  ticket  = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      long   magic   = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if(InpMagicNumber != 0 && magic != InpMagicNumber) continue;

      long   entry   = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT) continue; // Only closing deals

      double profit  = HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                       HistoryDealGetDouble(ticket, DEAL_SWAP)   +
                       HistoryDealGetDouble(ticket, DEAL_COMMISSION);

      if(firstDeal)
        {
         initialBalance  = currentBalance;
         runningBalance  = initialBalance;
         peakBalance     = initialBalance;
         firstDeal       = false;
        }

      totalTrades++;
      runningBalance += profit;
      sumProfits     += profit;
      sumSqProfits   += profit * profit;

      if(profit > 0)
        {
         wins++;
         grossProfit += profit;
         if(profit > maxWin) maxWin = profit;
        }
      else
        {
         losses++;
         grossLoss += MathAbs(profit);
         if(MathAbs(profit) > maxLoss) maxLoss = MathAbs(profit);
        }

      // Track drawdown
      if(runningBalance > peakBalance) peakBalance = runningBalance;
      double dd = (peakBalance - runningBalance) / (peakBalance > 0 ? peakBalance : 1) * 100.0;
      if(dd > maxDD) maxDD = dd;
     }

   if(totalTrades == 0)
     {
      MessageBox("No closed trades found for magic " + IntegerToString(InpMagicNumber),
                 "Ravan Backtest Report", MB_OK | MB_ICONINFORMATION);
      return;
     }

   // --- Calculate metrics ---
   double winRate      = (totalTrades > 0) ? (double)wins / totalTrades * 100.0 : 0.0;
   double profitFactor = (grossLoss > 0) ? grossProfit / grossLoss : (grossProfit > 0 ? 999.0 : 0.0);
   double avgTrade     = (totalTrades > 0) ? sumProfits / totalTrades : 0.0;
   double netProfit    = grossProfit - grossLoss;

   // Simplified Sharpe ratio (annualized assuming daily trades ~ 252 per year)
   double variance     = (totalTrades > 1)
                         ? (sumSqProfits - sumProfits * sumProfits / totalTrades) / (totalTrades - 1)
                         : 0.0;
   double stdDev       = (variance > 0) ? MathSqrt(variance) : 1.0;
   double sharpe       = (stdDev > 0) ? (avgTrade / stdDev) * MathSqrt(252.0) : 0.0;

   double recoveryFactor = (maxDD > 0) ? netProfit / (maxDD / 100.0 * initialBalance) : 0.0;
   // Note: initialBalance is approximated from current balance; for exact results
   // compare with your broker's backtest starting balance.

   // --- Build report strings ---
   string report = "";
   report += "=== RAVAN EA BACKTEST REPORT ===\n";
   report += "Generated: "     + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + "\n";
   report += "Symbol:    "     + _Symbol + "\n";
   report += "Period:    "     + EnumToString(_Period) + "\n";
   report += "Magic:     "     + IntegerToString(InpMagicNumber) + "\n\n";
   report += "--- PERFORMANCE ---\n";
   report += "Total Trades:    " + IntegerToString(totalTrades) + "\n";
   report += "Win Rate:        " + DoubleToString(winRate, 2) + "%\n";
   report += "Wins:            " + IntegerToString(wins) + "\n";
   report += "Losses:          " + IntegerToString(losses) + "\n";
   report += "Net Profit:      " + DoubleToString(netProfit, 2) + "\n";
   report += "Gross Profit:    " + DoubleToString(grossProfit, 2) + "\n";
   report += "Gross Loss:      " + DoubleToString(-grossLoss, 2) + "\n";
   report += "Profit Factor:   " + DoubleToString(profitFactor, 3) + "\n";
   report += "Avg Trade:       " + DoubleToString(avgTrade, 2) + "\n";
   report += "Best Trade:      " + DoubleToString(maxWin, 2) + "\n";
   report += "Worst Trade:     " + DoubleToString(-maxLoss, 2) + "\n\n";
   report += "--- RISK ---\n";
   report += "Max Drawdown:    " + DoubleToString(maxDD, 2) + "%\n";
   report += "Sharpe Ratio:    " + DoubleToString(sharpe, 3) + "\n";
   report += "Recovery Factor: " + DoubleToString(recoveryFactor, 3) + "\n";

   // --- Display in messagebox ---
   MessageBox(report, "Ravan EA Backtest Report", MB_OK | MB_ICONINFORMATION);

   // --- Export to CSV ---
   ExportToCSV(InpOutputFile,
               totalTrades, wins, losses, winRate,
               netProfit, grossProfit, grossLoss, profitFactor,
               avgTrade, maxWin, maxLoss, maxDD, sharpe, recoveryFactor);
  }

//-------------------------------------------------------------------
//  Export statistics to CSV
//-------------------------------------------------------------------
void ExportToCSV(string filename,
                 int    totalTrades,
                 int    wins,
                 int    losses,
                 double winRate,
                 double netProfit,
                 double grossProfit,
                 double grossLoss,
                 double profitFactor,
                 double avgTrade,
                 double maxWin,
                 double maxLoss,
                 double maxDD,
                 double sharpe,
                 double recoveryFactor)
  {
   string path = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + filename;
   int    handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_ANSI, ',');

   if(handle == INVALID_HANDLE)
     {
      Print("BacktestReport: Failed to open file '", filename, "'. Error=", GetLastError());
      return;
     }

   // Header row
   FileWrite(handle,
             "Metric", "Value");

   // Data rows
   FileWrite(handle, "Generated",        TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES));
   FileWrite(handle, "Symbol",           _Symbol);
   FileWrite(handle, "Period",           EnumToString(_Period));
   FileWrite(handle, "Total Trades",     IntegerToString(totalTrades));
   FileWrite(handle, "Wins",             IntegerToString(wins));
   FileWrite(handle, "Losses",           IntegerToString(losses));
   FileWrite(handle, "Win Rate (%)",     DoubleToString(winRate, 2));
   FileWrite(handle, "Net Profit",       DoubleToString(netProfit, 2));
   FileWrite(handle, "Gross Profit",     DoubleToString(grossProfit, 2));
   FileWrite(handle, "Gross Loss",       DoubleToString(-grossLoss, 2));
   FileWrite(handle, "Profit Factor",    DoubleToString(profitFactor, 3));
   FileWrite(handle, "Avg Trade",        DoubleToString(avgTrade, 2));
   FileWrite(handle, "Best Trade",       DoubleToString(maxWin, 2));
   FileWrite(handle, "Worst Trade",      DoubleToString(-maxLoss, 2));
   FileWrite(handle, "Max Drawdown (%)", DoubleToString(maxDD, 2));
   FileWrite(handle, "Sharpe Ratio",     DoubleToString(sharpe, 3));
   FileWrite(handle, "Recovery Factor",  DoubleToString(recoveryFactor, 3));

   FileClose(handle);
   Print("BacktestReport: Report saved to ", filename);
   MessageBox("CSV report saved to:\nMQL5\\Files\\" + filename,
              "Ravan Backtest Report — Saved", MB_OK | MB_ICONINFORMATION);
  }
//+------------------------------------------------------------------+
