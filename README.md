# Ravan EA — MT5 Expert Advisor Trading Suite

> **Production-ready MetaTrader 5 Expert Advisor designed for the MQL5 Market**  
> Multi-indicator confluence system | Auto-trading | Chart signals | Risk management

[![MQL5](https://img.shields.io/badge/Platform-MetaTrader%205-blue)](https://www.metatrader5.com/)
[![Language](https://img.shields.io/badge/Language-MQL5-orange)](https://www.mql5.com/)
[![Version](https://img.shields.io/badge/Version-1.0.0-green)](Docs/ChangeLog.md)
[![License](https://img.shields.io/badge/License-Commercial-red)](LICENSE)

---

## 🤖 What Is Ravan EA?

Ravan EA is a complete trading suite for MetaTrader 5, inspired by multi-indicator confluence systems like Ravan 2.0 on TradingView — but with **full auto-execution** through your MT5 broker.

It combines **7 independent indicators** into a single scoring system. A trade fires only when enough indicators agree, dramatically reducing false signals.

**Products included:**
- 🤖 **Expert Advisor** — Fully automated trading with risk management
- 📊 **Chart Indicator** — Visual buy/sell arrows + info dashboard (manual traders)
- 📜 **Backtest Report Script** — Enhanced statistics with CSV export
- ⚙️ **4 Ready-made Presets** — XAUUSD, EURUSD, GBPUSD, BTCUSD

---

## 🧠 Signal Engine — 7 Indicators

| # | Indicator | Weight | Purpose |
|---|---|---|---|
| 1 | EMA Crossover (9/21/50/200) | ⭐⭐⭐ | Trend direction |
| 2 | Supertrend (ATR-based) | ⭐⭐⭐ | Trend confirmation |
| 3 | ADX (>25 filter) | ⭐⭐ | Trend strength |
| 4 | RSI (oversold/overbought) | ⭐⭐ | Entry timing |
| 5 | Support/Resistance (auto-detected) | ⭐⭐⭐ | Key zones |
| 6 | Candlestick Patterns | ⭐ | Visual confirmation |
| 7 | Volume Analysis | ⭐ | Momentum |
| **Total** | | **±15** | |

**Signal fires when score ≥ threshold (default: 10/15)**

---

## 📁 Repository Structure

```
mt5-expert-advisor/
│
├── Expert Advisors/
│   └── RavanEA_MT5.mq5              # Main EA (auto-trading)
│
├── Indicators/
│   └── RavanSignals_MT5.mq5         # Chart indicator (buy/sell signals + dashboard)
│
├── Include/
│   ├── SignalEngine.mqh              # Multi-indicator confluence signal logic
│   ├── RiskManager.mqh              # Position sizing & risk management
│   ├── Dashboard.mqh                # On-chart visual dashboard panel
│   └── TradeManager.mqh             # SL/TP/trailing stop/partial close logic
│
├── Scripts/
│   └── BacktestReport.mq5           # Enhanced backtest report generator
│
├── Presets/
│   ├── XAUUSD_Scalping.set          # Gold scalping (M15)
│   ├── EURUSD_Swing.set             # EUR/USD swing (H4)
│   ├── GBPUSD_Day.set               # GBP/USD day trading (H1)
│   └── BTCUSD_Crypto.set            # BTC/USD crypto (H1)
│
├── Docs/
│   ├── UserManual.md                # Complete user guide with all parameters
│   ├── MarketDescription.md         # MQL5 Market product listing copy
│   └── ChangeLog.md                 # Version history
│
└── README.md                        # This file
```

---

## 🚀 Installation

### 1. Copy Files to MetaTrader 5

Open MT5 → **File → Open Data Folder** → navigate to `MQL5/`

```
MQL5/
├── Experts/       → RavanEA_MT5.mq5
├── Indicators/    → RavanSignals_MT5.mq5
├── Include/       → SignalEngine.mqh, RiskManager.mqh, TradeManager.mqh, Dashboard.mqh
└── Scripts/       → BacktestReport.mq5
```

### 2. Compile in MetaEditor

1. Press **F4** in MT5 to open MetaEditor
2. Find `Experts/RavanEA_MT5` in the Navigator
3. Press **F7** to compile
4. Verify: **0 errors, 0 warnings**
5. Repeat for `Indicators/RavanSignals_MT5`

### 3. Attach to Chart

1. Open a chart (e.g., XAUUSD M15)
2. Drag `RavanEA_MT5` from Navigator → Expert Advisors onto the chart
3. Load a preset: Inputs tab → **Load** → select a `.set` file
4. Enable AutoTrading (green button in toolbar)

---

## 📊 Backtesting

1. **Ctrl+R** to open Strategy Tester
2. Select `RavanEA_MT5`, set symbol and date range
3. Choose **"Every tick based on real ticks"** for accuracy
4. Run the backtest
5. Use `BacktestReport.mq5` script for enhanced statistics with CSV export

---

## ⚙️ Quick Preset Guide

| Preset | Pair | TF | Strategy |
|---|---|---|---|
| `XAUUSD_Scalping.set` | XAUUSD | M15 | Scalping |
| `EURUSD_Swing.set` | EURUSD | H4 | Swing |
| `GBPUSD_Day.set` | GBPUSD | H1 | Day Trading |
| `BTCUSD_Crypto.set` | BTCUSD | H1 | Crypto Trend |

---

## 💡 Selling on the MQL5 Market

1. Create a seller account at [mql5.com](https://www.mql5.com/en/users/login) → **Become a Seller**
2. Verify your identity (ID + selfie + proof of address)
3. Compile the EA → submit the `.ex5` file (source code stays private)
4. Use `Docs/MarketDescription.md` as your product listing copy
5. Add backtest screenshots as product images
6. Set your price ($99–$499 recommended for EAs)
7. MQL5 takes ~20% commission on sales

**Seller registration:** [https://www.mql5.com/en/articles/499](https://www.mql5.com/en/articles/499)

---

## 🛡️ MQL5 Market Compliance

- ✅ No external DLL imports
- ✅ No external network connections
- ✅ Error-free compilation
- ✅ Works in Strategy Tester
- ✅ Proper `#property` directives
- ✅ Magic number for trade identification
- ✅ Clean, professional code

---

## 📖 Documentation

- **[User Manual](Docs/UserManual.md)** — Full parameter reference, installation guide, FAQ
- **[Market Description](Docs/MarketDescription.md)** — Ready-to-use MQL5 Market listing
- **[Change Log](Docs/ChangeLog.md)** — Version history

---

## ⚠️ Risk Disclaimer

> Trading foreign exchange, gold, and cryptocurrencies involves substantial risk of loss. Automated trading systems can and do lose money. Never trade with money you cannot afford to lose. Past performance does not guarantee future results. This software is provided for educational purposes only and does not constitute financial advice.

---

## 🧑‍💻 Tech Stack

| Component | Technology |
|---|---|
| Language | MQL5 (C++-like) |
| Platform | MetaTrader 5 |
| Libraries | Standard MT5 Trade library (`CTrade`) |
| Charts | MT5 chart objects API |
| Indicators | Built-in MT5 indicator functions |

---

## 📄 License

Copyright © 2025 Ravan Trading Systems. All rights reserved.  
Compiled `.ex5` products are for personal use or resale via the MQL5 Market.  
Source code redistribution is not permitted.
