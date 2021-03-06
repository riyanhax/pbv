  
//+------------------------------------------------------------------+
//|                                      Atividade-02-A-08-10-19.mq5 |
//|                                            Copyright 2019, Hazen |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hazen"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{        

//+------------------------------------------------------+
//      Tamanho do total candlestick  => high - low      |
//      Tamanho do corpo              => close - open    |
//+------------------------------------------------------+
//      Formula de alta   | Tamanho do corpo > 0         |
//+------------------------------------------------------+
//      Tamanho do cabo               => open - low      |
//      Tamanho do top                => high - close    |
//+------------------------------------------------------+
//      Formula de baixa  | Tamanho do corpo < 0         |
//+------------------------------------------------------+
//      Tamanho do cabo               => close - low     |
//      Tamanho do top                => high - open     |
//+------------------------------------------------------+
//      Formula de Porsentagem                           |
//+------------------------------------------------------+
//      ((( Tamanho - cabo ) / tamanho ) * 100 ) - 100   |
//      ((( Tamanho - top ) / tamanho ) * 100 ) - 100    |
//      ((( Tamanho - corpo ) / tamanho ) * 100 ) - 100  |
//+------------------------------------------------------+
// So vai sera matelo ( Hammer ) se tiver com            |
// cabo maior ou igual 60% e                             |
// top menor ou igual 5%                                 |
// E se tiver depois de dois candlestick de baixa         |
// E antes de um candle de alta                           |
//+------------------------------------------------------+

//+------------------+--------------------------------------------------------------+
//  doc              | Links                                                        |
//+------------------+--------------------------------------------------------------+
// MqlRates          | https://www.mql5.com/pt/docs/constants/structures/mqlrates   |
//+------------------+--------------------------------------------------------------+
// ArraySetAsSeries  | https://www.mql5.com/pt/docs/array/arraysetasseries          |
//+------------------+--------------------------------------------------------------+
// CopyRates         | https://www.mql5.com/pt/docs/series/copyrates                |
//+------------------+--------------------------------------------------------------+
// MathMin           | https://www.mql5.com/pt/docs/math/mathmin                    |
//+------------------+--------------------------------------------------------------+
// Imagen            | http://daltonvieira.com/wp-content/uploads/2010/10/hammer.gif|
//+------------------+--------------------------------------------------------------+



   MqlRates rates[];
   ArraySetAsSeries(rates, true); // o candle mais atual passa ser o índice zero do vetor
   
//   variaveis
 
   int quantidadeCandle = 100;
   int totalCopiado = CopyRates(_Symbol, 0, 0, quantidadeCandle , rates);
   double tamTotal , corpo , cabo , pCabo , top , pTop ;
         
   
   if(totalCopiado > 0) {   
      Print("Candles copiados: " + totalCopiado);      
      int size = MathMin( totalCopiado, quantidadeCandle );
      
      for(int i = 0; i < size; i++) {
      
         if ( size > ( i + 3 ) ){
         
            tamTotal = rates[i + 1].high - rates[i + 1].low ;
            corpo = rates[i + 1].close - rates[i + 1].open ;
         
//          Para candle de alta 
            if ( corpo > 0 ) {
               cabo = rates[i + 1].open - rates[i + 1].low ;
               top = rates[i + 1].high - rates[i + 1].close ;
            }
//          Para candle de baixa
            if ( corpo < 0 ) {
               cabo = rates[i + 1].close - rates[i + 1].low ;
               top = rates[i + 1].high - rates[i + 1].open ;
               corpo *= -1 ;         
            }
            pCabo = calcularPorcentagem( tamTotal ,cabo );
            pTop  = calcularPorcentagem( tamTotal , top );
            
//          Martelo de baixa 
            if ( rates[i + 3].open > rates[i + 3].close && rates[i + 2].open > rates[i + 2].close  ){
               if ( rates[i].open < rates[i].close ) {
                 if ( pCabo >= 60 && pTop <= 5  ) {
                    Print("Mardelo " + rates[i + 1].time);
                 }
               }            
            }
//          Martelo invertido
            if ( rates[i + 3].open < rates[i + 3].close && rates[i + 2].open < rates[i + 2].close  ){
               if ( rates[i].open > rates[i].close ) {
                 if ( pCabo <= 5 && pTop >= 60  ) {
                    Print("Mardelo invertido " + rates[i + 1].time);
                 }
               }            
            }

            
         }
      
//-------- fim do for ------------
      }
   }else Print("Falha ao receber dados históricos do ativo ", _Symbol );
   
//-------- fim da OnStart ---------
}

//+-------------------------------------------------------------+
//| Funcao de calcular porcentagem de cada parte do candlestick |
//+-------------------------------------------------------------+
double calcularPorcentagem ( double valor , double tamanho )
{
   return ( valor / tamanho ) * 100 ;
}
