#include <iostream>
#include <fstream>
#include <vector>
#include "TROOT.h"
#include "TString.h"
#include "TFile.h"
#include "TH1F.h"
#include "TGraphAsymmErrors.h"
#include "TMultiGraph.h"
#include "TCanvas.h"
#include "TGraph.h"

void plot_1D2 ( TString filename = "iter", TString title ="", TString xlabel ="Number of Iterations", TString ylabel ="FoM" )
{
  ifstream read ( "output/"+filename+".ascii" );

  double a, b, c;
  vector<double> xvar, ytest, ytrain;

  do{
    read >> a >> b >> c;
    if (!read.good()) {
      std::cout << "Format error in " << "output/" <<filename << ".ascii" << std::endl;
      std::cout << "Input was: " << a << " " << b << " " << c << std::endl;
    }
    xvar.push_back(a);
    ytest.push_back(b);
    ytrain.push_back(c); 
  } while ( !read.eof() );

  const int size= xvar.size();
  
  TCanvas* window=new TCanvas( "window", title, 700, 500);
  TMultiGraph* mg = new TMultiGraph();
  mg->SetTitle(title);

  TGraphAsymmErrors* test = new TGraphAsymmErrors( size, &xvar[0], &ytest[0]);
  //  test->SetTitle(title);
  test->SetMarkerColor(9);
  test->SetLineColor(9);
  test->SetMarkerStyle(20); // Point
  //  test->SetMarkerSize(40);

  TGraphAsymmErrors* train = new TGraphAsymmErrors( size, &xvar[0], &ytrain[0]);
  //  train->SetTitle(title);
  train->SetMarkerColor(8);
  train->SetLineColor(8);
  train->SetMarkerStyle(20); // Point
  //  train->SetMarkerSize(40);

  gStyle->SetOptStat(0);
  //  test->SetLineColor(kRed);
  //  train->SetLineColor(kBlue);

  TLegend *leg=new TLegend(0.65,0.2,0.85,0.3);
  leg->AddEntry(test,"Test-Data","lep");
  leg->AddEntry(train,"Train-Data","lep");
  leg->SetFillColor(10);
  leg->SetShadowColor(10);
  leg->SetLineColor(10);

  mg->Add(test);
  mg->Add(train);
  mg->Draw("ALP Same"); // axis, points, straight lines

  mg->SetMinimum(1.);
  mg->SetMaximum(3.);
  mg->GetXaxis()->SetTitle(xlabel);
  mg->GetYaxis()->SetTitle(ylabel);
  mg->GetXaxis()->CenterTitle();
  mg->GetYaxis()->CenterTitle();

  leg->Draw();

  window->SaveAs("output/plot_"+filename+".pdf");
}


