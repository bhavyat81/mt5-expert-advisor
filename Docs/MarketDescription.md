# Ravan EA — MQL5 Market Product Description

> *Ready-to-use product listing copy for the MQL5 Market submission*

---

## 🤖 Ravan EA — Multi-Indicator Confluence Expert Advisor for MT5

**The most comprehensive signal-based Expert Advisor available on the MQL5 Market.**

Ravan EA combines **7 powerful indicators** into a single confluence scoring system — trades only fire when multiple indicators align, dramatically reducing false signals and improving accuracy across all market conditions.

---

## ⭐ Key Features

### 🧠 7-Indicator Confluence Engine
All 7 indicators are calculated natively in MQL5 — **no external DLLs, no subscriptions**:

| Indicator | Purpose | Weight |
|---|---|---|
| EMA Crossover (9/21/50/200) | Trend direction | ⭐⭐⭐ |
| Supertrend (ATR-based) | Trend confirmation | ⭐⭐⭐ |
| ADX (configurable threshold) | Trend strength filter | ⭐⭐ |
| RSI (oversold/overbought) | Entry timing | ⭐⭐ |
| Support/Resistance (auto-detected) | Key price zones | ⭐⭐⭐ |
| Candlestick Patterns | Visual confirmation | ⭐ |
| Volume Analysis | Momentum confirmation | ⭐ |

**Maximum Score: 15** — A trade only executes when the confluence score reaches your threshold (default: 10/15).

### 📊 Professional On-Chart Dashboard
- Real-time account stats: balance, equity, margin
- Live signal direction and strength percentage
- Individual indicator states shown per update
- Current spread and ATR value
- Next support/resistance levels

### 💰 Advanced Risk Management
- **Risk-based position sizing** — automatically calculates lot size from your risk % per trade
- **Max drawdown protection** — halts trading if drawdown exceeds your limit
- **Daily loss protection** — stops new trades if daily loss limit is hit
- **Max positions control** — never over-expose your account
- **Spread filter** — skips trades when spread is too wide

### 🔄 Intelligent Trade Management
- **Trailing stop** with configurable distance and step
- **Break-even stop** — moves SL to entry after defined profit
- **Partial close** — take profits at TP1 and TP2 levels
- **Multi-timeframe** — signals calculated on higher timeframe, executed on chart timeframe

### ⚙️ Highly Configurable
Every parameter is adjustable with detailed tooltips. Switch any indicator on/off. 4 ready-made presets included.

### ✅ MQL5 Market Compliant
- No external DLLs
- No internet connections required
- Works in Strategy Tester (backtesting compatible)
- Error-free compilation

---

## 📦 What's Included

| Component | Description |
|---|---|
| **RavanEA_MT5.mq5** | Main Expert Advisor with full auto-trading |
| **RavanSignals_MT5.mq5** | Standalone chart indicator (buy/sell arrows + dashboard) |
| **SignalEngine.mqh** | Core signal logic library |
| **RiskManager.mqh** | Risk management library |
| **TradeManager.mqh** | Trade execution library |
| **Dashboard.mqh** | Visual dashboard library |
| **BacktestReport.mq5** | Enhanced backtest statistics script |
| **4 Preset files** | XAUUSD, EURUSD, GBPUSD, BTCUSD optimized settings |
| **Full documentation** | User manual, changelog |

---

## 🎯 Recommended Pairs & Timeframes

| Pair | Timeframe | Strategy | Preset |
|---|---|---|---|
| **XAUUSD (Gold)** ⭐ | M15 | Scalping | `XAUUSD_Scalping.set` |
| EURUSD | H4 | Swing | `EURUSD_Swing.set` |
| GBPUSD | H1 | Day Trading | `GBPUSD_Day.set` |
| BTCUSD | H1 | Trend Following | `BTCUSD_Crypto.set` |
| USDJPY | H1/H4 | Any | Customize settings |
| AUDUSD | H1/H4 | Any | Customize settings |

---

## ⚙️ Input Parameters Overview

**70+ configurable parameters organized into groups:**

- **Trade Settings** — lot size, magic number, max positions, comment
- **Signal Settings** — enable/disable each of 7 indicators, confluence threshold
- **ADX Settings** — period, minimum level
- **RSI Settings** — period, oversold/overbought levels
- **Supertrend Settings** — ATR period, multiplier
- **S/R Settings** — lookback period, zone tolerance
- **Risk Management** — risk %, max drawdown %, max daily loss %
- **SL/TP Settings** — fixed points or ATR-based, risk:reward ratio
- **Trailing Stop** — enable, distance, step
- **Break-Even** — enable, profit trigger, offset
- **Partial Close** — enable, TP1/TP2 levels, percentages
- **Spread Filter** — maximum allowed spread
- **Time Filter** — trading hours, skip days
- **Dashboard** — show/hide

---

## 📋 System Requirements

- **Platform:** MetaTrader 5 (build 3000+)
- **OS:** Windows 7/10/11
- **Broker:** Any MT5-compatible broker
- **Account Type:** Any (Standard, ECN, Raw Spread recommended)
- **No DLLs required**
- **No external services required**

---

## ⚠️ Important Notice

> Trading foreign exchange, gold, and cryptocurrencies carries significant risk. Past performance is not indicative of future results. Always test on a demo account before trading with real money. This product is provided as-is for educational purposes and does not constitute financial advice.

---

## 🏆 Why Choose Ravan EA?

✅ **Non-repainting signals** — arrows never change after bar closes  
✅ **7 indicators, 1 system** — no need to buy multiple tools  
✅ **Fully automated** — set and let it run  
✅ **Fully transparent** — see every indicator's contribution on the dashboard  
✅ **Risk-first design** — never risks more than you specify  
✅ **Active development** — regular updates and support  
✅ **Proven backtests** — optimized for Gold (XAUUSD), the world's most popular trading instrument  

---

*Ravan EA v1.0 | Copyright 2025 Ravan Trading Systems*
