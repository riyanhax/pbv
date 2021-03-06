//+------------------------------------------------------------------+
//|                                               PBV-Elliot-001.mq5 |
//|                                                   Gerson Pereira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Gerson Pereira"
#property link      "https://www.mql5.com"
#property version   "1.00"
#resource "\\Indicators\\Examples\\ZigZag.ex5";

#include <Trade\AccountInfo.mqh>
CAccountInfo infoConta;

#include <Trade\SymbolInfo.mqh>
CSymbolInfo ativoInfo;

#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\OrderInfo.mqh>
COrderInfo ordPend;

#include <ChartObjects\ChartObjectsArrows.mqh>
CChartObjectArrow icone;

datetime tempoCandleBuffer[];
int idRobo = 123456789 ;

long     volumeBuffer[];
double   zzTopoBuffer[];
double   zzFundoBuffer[];
datetime zzDataFundo[];
datetime zzDataTopo[];

int      totalCopiarBuffer = 100;
int      zzHandle;

input double margem_StopLoss = 10 ; // Margem para StopLoss
input double margem_TakeProfit = 0.6380; // Margem para TakeProfit
input double regiaoPrecoInicio = 0.9360; // Região de preço de início 
input double regiaoPrecoFim = 1.2360; // Região de preço de fim 

double valorStopLossCompra = 0;
double valorTakeProfitCompra = 0;

double valorStopLossVenda = 0;
double valorTakeProfitVenda = 0;



input int zzProfundidade = 30;
input double volumeOperacao = 10;
input datetime mercadoHoraInicio = "09:10:00" ;
input datetime mercadoHoraFim = "17:50:00" ;











//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   zzHandle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5", zzProfundidade);
   if(zzHandle == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag: ", GetLastError());
      return(INIT_FAILED);
   }

   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);
   ArraySetAsSeries(zzDataFundo, true);
   ArraySetAsSeries(zzDataTopo, true);


   double   saldo = infoConta.Balance();
   double   lucro = infoConta.Profit();
   double   margemDisp = infoConta.FreeMargin();
   bool     isPermitidoTrade = infoConta.TradeAllowed();
   bool     isPermitidoRobo = infoConta.TradeExpert();    //Slide -> isPermitidoRoto
   // ...
   // Print("Saldo: ", saldo, " ", margemDisp);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(zzHandle);
   fecharTodasOrdensPendentesRobo();
   fecharTodasPosicoesRobo();

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---

   // Se o horário não confere com o setup, fechar todas as posições e ordens
   if(TimeCurrent() < mercadoHoraInicio && TimeCurrent() > mercadoHoraFim) {
      fecharTodasOrdensPendentesRobo();
      fecharTodasPosicoesRobo();
      return;
   }

   // Se o ativo ainda não estiver sincronizado, retornar.
   if(!ativoInfo.IsSynchronized()) {
      return ;
   }

   // copia os topos
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzTopoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos topos A: ", GetLastError());
      return;
   }

   // copia os fundos
   if(CopyBuffer(zzHandle, 2, 0, totalCopiarBuffer, zzFundoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos fundos A: ", GetLastError());
      return;
   }

   // Copiar datas e horas dos fundos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundo) < 0) {
      Print("ERRO ao copiar datas fundos A");
      return;
   }

   // Copiar datas e horas dos topos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopo) < 0) {
      Print("ERRO ao copiar datas topos A");
      return;
   }


   string nomeIcone = "icone";

   int nrTopoA = 0;
   int nrFundoA = 0 ;

   int tamArrayTopo = ArraySize(zzTopoBuffer);
   int tamArrayFundo = ArraySize(zzFundoBuffer);

   double   precoTopoAtual;
   double   precoTopoAnterior;
   datetime dataTopoAtual;
   datetime dataTopoAnterior;

   double   precoFundoAtual;
   double   precoFundoAnterior;
   datetime dataFundoAtual;
   datetime dataFundoAnterior;

   //---------------------
   // Laço para buscar os topos
   for(int i = 0 ; i < tamArrayTopo ; i++) {

      // processar topos
      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopoA == 0 ) {
            precoTopoAtual = zzTopoBuffer[i];
            dataTopoAtual = zzDataTopo[i];
            nomeIcone = "topoAtual";
            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAtual, dataTopoAtual, clrRed, 233, 1);

         } else if( nrTopoA == 1) {
            precoTopoAnterior = zzTopoBuffer[i];
            dataTopoAnterior = zzDataTopo[i];
            nomeIcone = "topoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAnterior, dataTopoAnterior, clrBlue, 233, 1);

            break;
         } // Fim da condição para obter o topo anterior

         nrTopoA++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos
   for(int i = 0 ; i < tamArrayFundo ; i++) {
      // processar fundos
      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundoA == 0 ) {
            precoFundoAtual = zzFundoBuffer[i];
            dataFundoAtual = zzDataFundo[i];
            nomeIcone = "fundoAtual";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 234, 1);

         } else if( nrFundoA == 1) {
            precoFundoAnterior = zzFundoBuffer[i];
            dataFundoAnterior = zzDataFundo[i];
            nomeIcone = "fundoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAnterior, dataFundoAnterior, clrBlue, 234, 1);

            break;
         } // Fim da condição para obter o topo anterior
         nrFundoA++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos




// Tratar com topos e fundos
//----------------------------
   if(dataFundoAtual > dataTopoAtual) {
      //Print("Compra");
      // Cálculos de volume
      double volumeAnterior = somarVolume(dataFundoAnterior, dataTopoAtual);
      double volumeAtual = somarVolume(dataTopoAtual, dataFundoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      // Preço atual do ativo
      double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      
      // Definições das regiões de entrada para operações de compra
      double precoCompraRegiao1 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * regiaoPrecoInicio) ;
      double precoCompraRegiao2 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * regiaoPrecoFim) ;

      valorStopLossCompra   = NormalizeDouble( precoAtual - ((precoTopoAtual - precoFundoAnterior) * margem_StopLoss), 0) ;
      valorTakeProfitCompra = NormalizeDouble( precoAtual + ((precoTopoAtual - precoFundoAnterior) * margem_TakeProfit), 0) ;

      double stopLoss = NormalizeDouble(MathRound(valorStopLossCompra / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);
      double takeProfit = NormalizeDouble(MathRound(valorTakeProfitCompra / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);


      if( precoAtual <= precoCompraRegiao1 && precoAtual >= precoCompraRegiao2 && volumeAnterior > volumeAtual ) {
      //if( precoAtual >= precoCompraRegiao2 && precoAtual <= precoCompraRegiao1 ) {
         if( buscarPosicaoAbertasByTipo(POSITION_TYPE_SELL) == false && buscarPosicaoAbertasByTipo(POSITION_TYPE_BUY) == false ) {
            desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrBlue, 221, 1);
            //fecharTodasOrdensPendentesRobo();
            //fecharTodasPosicoesRobo();
            
            abrirOrdem(ORDER_TYPE_BUY, ativoInfo.Ask(), volumeOperacao, stopLoss, takeProfit, "compra");
         }
      }
   } else {
      //Print("Venda");

      double volumeAnterior = somarVolume(dataTopoAnterior, dataFundoAtual);
      double volumeAtual = somarVolume(dataFundoAtual, dataTopoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      double precoVendaRegiao1 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * regiaoPrecoInicio) ;
      double precoVendaRegiao2 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * regiaoPrecoFim) ;

      valorStopLossVenda   = NormalizeDouble( precoAtual + ((precoTopoAnterior - precoFundoAtual) * margem_StopLoss), 0) ;
      valorTakeProfitVenda = NormalizeDouble( precoAtual - ((precoTopoAnterior - precoFundoAtual) * margem_TakeProfit), 0) ;

      double stopLoss = NormalizeDouble(MathRound(valorStopLossVenda / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);
      double takeProfit = NormalizeDouble(MathRound(valorTakeProfitVenda / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);


      if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 && volumeAnterior > volumeAtual ) {
      //if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 ) {
         // Print("Preço na região de VENDA");
         if(buscarPosicaoAbertasByTipo(POSITION_TYPE_SELL) == false && buscarPosicaoAbertasByTipo(POSITION_TYPE_BUY) == false) {
            //Print("Abrindo ordem de venda");
            //desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 222, 1);
            //fecharTodasOrdensPendentesRobo();
            //fecharTodasPosicoesRobo();
            abrirOrdem(ORDER_TYPE_SELL, ativoInfo.Bid(), volumeOperacao, stopLoss, takeProfit, "venda");

         }
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double somarVolume(datetime dataInicial, datetime dataFinal)
{
   int totalCopiado = CopyRealVolume(_Symbol, _Period, dataInicial, dataFinal, volumeBuffer);
   if( totalCopiado < 0) {
      return -1;
   }

   double somaVolume = 0;
   for(int i = 0; i < totalCopiado; i++) {
      somaVolume += volumeBuffer[i];
   }

   return somaVolume;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl, double tp, string coment = "")
{

   //+-------------------------------------------------------+
   bool result  ; // variável não inicializada no slide
   //+-------------------------------------------------------+

   preco = NormalizeDouble(preco, _Digits);
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   trade.SetExpertMagicNumber(idRobo);
   trade.SetTypeFillingBySymbol(_Symbol);


   if(tipoOrdem == ORDER_TYPE_BUY) {
      result = trade.Buy(volume, _Symbol, preco, sl, tp, coment);
   } else if (tipoOrdem == ORDER_TYPE_SELL) {
      result = trade.Sell(volume, _Symbol, preco, sl, tp, coment);
   } else if(tipoOrdem == ORDER_TYPE_BUY_LIMIT) {
      result = trade.BuyLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);
   } else if(tipoOrdem == ORDER_TYPE_SELL_LIMIT) {
      result = trade.SellLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);
   }
   if(!result) {
      Print("Erro ao abrir a ordem ", tipoOrdem, ". Código: ", trade.ResultRetcode() );
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fecharTodasPosicoesRobo()
{
   double saldo = 0;
   int totalPosicoes = PositionsTotal();
   for(int i = 0; i < totalPosicoes; i++) {
      string simbolo = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if( simbolo == _Symbol && magic == idRobo ) {
         saldo = PositionGetDouble(POSITION_PROFIT);
         if(!trade.PositionClose(PositionGetTicket(i))) {
            Print("Erro ao fechar a negociação. Código: ", trade.ResultRetcode());
         } else {
            Print("Saldo: ", saldo);
         }
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obterHistoricoNegociacaoRobo()
{

   //Funções de Negociação
   HistorySelect(0, TimeCurrent());
   uint total = HistoryDealsTotal();
   ulong ticket = 0;
   double price, profit;
   datetime time;
   string symbol;
   long type, entry;
   for(uint i = 0; i < total; i++) {
      if((ticket = HistoryDealGetTicket(i)) > 0) {
         price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         type = HistoryDealGetInteger(ticket, DEAL_TYPE);
         entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if( entry == DEAL_ENTRY_OUT ) {
            Print("Ativo: ", symbol, " - Preço saída: ", price, " - Lucro: ", profit);
         }
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fecharTodasOrdensPendentesRobo()
{
   for(int i = OrdersTotal() - 1 ; i >= 0; i--) {

      // seleciona a ordem pendente por seu índice
      if( ordPend.SelectByIndex(i) ) {

         // se a ordem pendente for do ativo monitorado e aberta pelo robô
         if(ordPend.Symbol() == _Symbol && ordPend.Magic() == idRobo) {
            if (!trade.OrderDelete(ordPend.Ticket() ) ) {
               Print("Erro ao excluir a ordem pendente ", ordPend.Ticket());
            }
         }
      }
   }
}




//+------------------------------------------------------------------+



// ---------------------------------------------------------------------
// Método responsável por remover o icone de todo do gráfico pelo nome
// ---------------------------------------------------------------------
void removerIcone(string nome)
{

// remove
   ObjectDelete(0, nome);

// Print("REMOVER: ", nome);
   ChartRedraw();

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void desenharIcone (string nome, double preco, datetime data, color cor, int codigoIcone, int tamIcone)
{

   icone.Create(0, nome, 0, data, preco, codigoIcone) ;
   icone.Color(cor);
   icone.Width(tamIcone);

}
//+------------------------------------------------------------------+



//----------------------------------------------------------------------+
// Função responsável por verificar se há posições abertas por tipo.    |
//----------------------------------------------------------------------+
bool buscarPosicaoAbertasByTipo(ENUM_POSITION_TYPE tipoPosicaoBusca)
{

   int totalPosicoes = PositionsTotal();
   //Alert("POSICOES ABERTAS: " + totalPosicoes + " - Tipo posicao busca: " + EnumToString(tipoPosicaoBusca) );
   double lucroPosicao;

   for(int i = 0; i < totalPosicoes; i++) {

      // obtém o nome do símbolo a qual a posição foi aberta
      string simbolo = PositionGetSymbol(i);

      if(simbolo != "") {

         // id do robô
         ulong  magic = PositionGetInteger(POSITION_MAGIC);
         lucroPosicao = PositionGetDouble(POSITION_PROFIT);
         ENUM_POSITION_TYPE tipoPosicaoAberta = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         // obtém o simbolo da posição
         string simboloPosicao = PositionGetString(POSITION_SYMBOL);

         // se é o robô e ativo em questão
         if( simboloPosicao == _Symbol && magic == idRobo) {

            // caso operação
            if(tipoPosicaoBusca == tipoPosicaoAberta) {

               //Print("RETORNO POSICAO ABERTA: " + EnumToString(tipoPosicaoAberta) + " - ROBO: " + magic);
               //Print("TEM VENDA");
               return true;
            }
         } // fim magic

      } else {
         PrintFormat("Erro quando recebeu a posição do cache com o indice %d." + " Error code: %d", i, GetLastError());
         ResetLastError();
      }

   } // fim for

   return false;

}
//+------------------------------------------------------------------+