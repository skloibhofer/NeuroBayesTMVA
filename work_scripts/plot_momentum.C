#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include "TROOT.h"
#include "TStyle.h"
#include "TString.h"
#include "TFile.h"
#include "TH1F.h"
#include "TH2.h"
#include "TGraph2D.h"
#include "TCanvas.h"
#include "TGraph.h"
#include "TLatex.h"

void plot_momentum ( TString filename = "momentum_iter_short", TString title ="", TString xlabel ="Momentum", TString ylabel ="Number of Iterations", bool xlog=1, bool ylog=0 )
{
  ifstream read ( "output/"+filename+".ascii" );
  if (!read.is_open()) { 
    std::cerr << "Unable to open input file " << "output/" << filename << ".ascii" << std::endl;
    exit(1);
  };
  float x, y, z;
  vector<float> xval, yval;
  vector<float> xyz[3];

  // Get XValues
  string tempxstring;
  getline( read, tempxstring );
  std::stringstream xread ( tempxstring, ios_base::in );  xread.seekg (9);
  while ( xread >> x ) {
    xval.push_back(x);
  }
  // Get YValues
  while ( read >> y ){
    if ( ! (read.good()) ) std::cerr << "Somethings wrong with the input file " << filename << std::endl;
    yval.push_back(y);
    // Get ZValues and insert all
    for ( size_t it(0); it < xval.size(); ++it ) {
      read >> z; // std::cerr << " " << z << " "; // Shows that all values are read in
      if(xval[it]!=0) {
	xyz[0].push_back(xval[it]);
      } else {
	xyz[0].push_back( 0.6*xval[it+1] );
      }
      xyz[1].push_back(y);
      xyz[2].push_back(z);
    }
  } 

  // Build Bin-Structure for x
  const size_t n_xbins(xval.size()+1);
  float xbins[n_xbins];
  xbins[0] = xval[0]+(xval[1]-xval[0])*0.5;
  xbins[1] = (xval[1]-xval[0])*0.8;
  for ( size_t it(2); it<(n_xbins-1); ++it ) {
    xbins[it] = (xval[it-1] + xval[it]) /2 ;
  }
  //  xbins[n_xbins-1]=1.01*xval[n_xbins-2]; // nicer version..
  xbins[n_xbins-1]=1.; 
  // And for y
  const size_t n_ybins(yval.size()+1);
  float ybins[n_ybins];
  ybins[0] = yval[0];
  for ( size_t it(1); it<(n_ybins-1); ++it ) {
    ybins[it] = (yval[it-1] + yval[it]) /2 ;
  }
  ybins[n_ybins-1]=1.01+yval[n_ybins-2]; // 
  TH2F* plot = new TH2F( filename, title, n_xbins-1, &xbins[0], n_ybins-1, &ybins[0] );
  // fill
  for ( size_t it(0); it < xyz[0].size(); ++it ) {
    plot->Fill( xyz[0][it], xyz[1][it], xyz[2][it] );
  }

  gStyle->SetOptStat(0); 
  plot->SetMarkerSize(1.5);
  gStyle->SetPaintTextFormat("1.3g");
  TCanvas* window=new TCanvas( "window", title, 700, 500);

  plot->SetTitle(title);
  plot->GetXaxis()->SetTitle(xlabel);
  plot->GetYaxis()->SetTitle(ylabel);
  //  plot->GetZaxis()->SetTitle("FoM");
  plot->GetXaxis()->CenterTitle();
  plot->GetYaxis()->CenterTitle();
  if (xlog==1) window->SetLogx(1);
  if (ylog==1) window->SetLogy(1);
  //  plot->SetAxisRange(0.005,1.,"X");


  plot->Draw("colztext");

  TLatex* t = new TLatex( 0.94, 0.07, "FoM" );
  t->SetNDC();
  t->SetTextSize(0.035);
  //    t->AppendPad();
  t->Draw();


  window->SaveAs("output/pl2d_"+filename+".pdf");

}
