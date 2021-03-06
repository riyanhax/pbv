//+------------------------------------------------------------------+
//|                                          exercicio_03_abcdef.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   MqlRates arrayCandles[];
   ArraySetAsSeries(arrayCandles, true); // o candle mais atual passa ser o índice zero do vetor

   string dataMaior;
   string menorPrecoData ;
   string maiorPrecoData ;
   double maiorVolume;
   string dataMenor;
   double menorVolume = 10000000000000000;
   double volumeTotal;
   double menorPreco = 10000000000000000;
   double maiorPreco;
   int alta = 0;
   int baixa = 0;
   int lado = 0;
   string res;
   int copiarCandles = 100 ;

   int candlesCopiados = CopyRates(_Symbol, 0, 0, copiarCandles, arrayCandles);

   if(candlesCopiados > 0) {

      Print("Candles copiados: ", candlesCopiados);

      int qtdeCandlesCopiados = MathMin( candlesCopiados, copiarCandles );

      for(int i=0; i < qtdeCandlesCopiados; i++) {

//         A

         if (maiorVolume < arrayCandles[i].tick_volume ) {
            maiorVolume = arrayCandles[i].tick_volume;
            dataMaior = TimeToString(arrayCandles[i].time);
         }

//         B

         if ( menorVolume > arrayCandles[i].tick_volume ) {
            menorVolume = arrayCandles[i].tick_volume;
            dataMenor = TimeToString(arrayCandles[i].time);
         }

//         C

         volumeTotal += arrayCandles[i].tick_volume;

//         D

         if ( maiorPreco < arrayCandles[i].high ) {
            maiorPreco = arrayCandles[i].high;
            maiorPrecoData = TimeToString(arrayCandles[i].time) ;
         }
         if ( menorPreco > arrayCandles[i].low ) {
            menorPreco = arrayCandles[i].low ;
            menorPrecoData = TimeToString(arrayCandles[i].time);
         }

//         E

         if ( i > 0 ) {

            // Print("Valor de i : ", i,"/", qtdeCandlesCopiados, " - Data Candle : ", arrayCandles[i].time );

            if (  arrayCandles[i].close < arrayCandles[i - 1].open ) {
               alta += 1;
            } else if (arrayCandles[1].close > arrayCandles[i - 1].open) {
               baixa += 1;
            } else {
               lado += 1;
            }
         }

// Fim do for

      }

//      E

      if ( alta > baixa && alta > lado ) {
         res = "Alta";
      } else if ( baixa < alta && baixa < lado ) {
         res = "Baixa";
      } else {
         res = "Lateralizado";
      }


      // Saidas
      Print("Atividade 03");
      Print("<- A ->");
      Print("A data do candle com maior volume negociado ", dataMaior);

      Print("<- B ->");
      Print("A data com menor volume negociado " + dataMenor);

      Print("<- C ->");
      Print("Volume total acumulado negociado do período " + volumeTotal);

      Print("<- D ->");
      Print(" Menor preço do período : ", menorPreco, " - Em..: ", menorPrecoData );
      Print(" Maior preço do período : ", maiorPreco, " - Em..: ", maiorPrecoData );

      Print("<- E ->");
      Print("O mercado esta de " + res);
      Print("Alta  : ", alta);
      Print("Baixa : ", baixa) ;
      Print("Lado  : ", lado) ;



   } else Print("Falha ao receber dados históricos do ativo ", _Symbol );
}

//+------------------------------------------------------------------+
