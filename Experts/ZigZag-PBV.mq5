//+------------------------------------------------------------------+
//|                                                        teste.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsLines.mqh>
CChartObjectTrend linha;

#resource "\\Indicators\\Examples\\ZigZag.ex5";
double zzTopoBuffer[];
double zzFundoBuffer[];
datetime tempoCandleBuffer[];
int zzHandle;
int totalCopiarBuffer=100;
double precoTopoAtual;
double precoTopoAnt;
datetime dataTopoAtual;
datetime dataTopoAnt;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   zzHandle=iCustom(_Symbol,_Period,"::Indicators\\Examples\\ZigZag.ex5");
   if(zzHandle==INVALID_HANDLE)
     {
      Print("Falha ao criar o indicador ZigZag: ",GetLastError());
      return(INIT_FAILED);
     }
// define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer,true);
   ArraySetAsSeries(zzFundoBuffer,true);
   ArraySetAsSeries(tempoCandleBuffer,true);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
// copia os topos
   if(CopyBuffer(zzHandle,1,0,totalCopiarBuffer,zzTopoBuffer)<0)
     {
      Print("Erro ao copiar dados dos topos: ",GetLastError());
      return;
     }
   if(CopyTime(_Symbol,_Period,0,totalCopiarBuffer,tempoCandleBuffer)<0)
     {
      Print("Erro ao copiar dados dos datas : ",GetLastError());
      return;
     }

   int tamVet = ArraySize ( zzTopoBuffer );
   int nrTopo = 0;
   for(int i=0; i<tamVet; i++)
     {
      if(zzTopoBuffer[i]!=0)
        {
         if(nrTopo==0)
           {
            dataTopoAtual=tempoCandleBuffer[i];
            precoTopoAtual=zzTopoBuffer[i];
           
           }else if(nrTopo==1) {
            dataTopoAnt=tempoCandleBuffer[i];
            precoTopoAnt=zzTopoBuffer[i];
            
                        criarLinha("alta" + MathRand(), precoTopoAnt, dataTopoAnt, precoTopoAtual, dataTopoAtual);
            
            break;
           }
         nrTopo++;
        }
     } // fim for topo para obter apenas os dois últimos topos mais atuais
  }
//+------------------------------------------------------------------+


void criarLinha(string nome, double p1, datetime t1, double p2, datetime t2){
      linha.Create(0, nome, 0, t1, p1, t2, p2);
      linha.Style(STYLE_DOT);
      linha.Color(clrRed);
      linha.Width(1);
      linha.RayRight(true);

}
//+------------------------------------------------------------------+
//| Expert deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(zzHandle);
  }
//+------------------------------------------------------------------+
