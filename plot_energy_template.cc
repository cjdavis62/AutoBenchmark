/*
This script compares MC between a prior MC spectrum with a user generated MC spectrum  
The plots are divided into a few types: All Multiplicities, M1, M2, and Multiplicity > 2
Each plot contains the spectrum for both old and new MC
The spectra are normalized to the old spectra for each of the MC
The plots are binned per 1 keV including a smaller plot of the residuals in the canvas

This script is run via benchmarkCheck_root.py
It is a template to be adjusted with the parameters from the python script
Adjusted variables are labelled with leading and trailing "_"
*/

// Written by Christopher Davis
// Version 1.0 8Mar2016

#include "TROOT.h"
#include "TTree.h"
#include "TSystem.h"
#include "TFile.h"
#include "TH1.h"
#include "TH1F.h"
#include "TH1D.h"
#include "TGraph.h"
#include "TGraphAsymmErrors.h"
#include "TStyle.h"
#include "TCanvas.h"
#include "TLegend.h"
#include "TCut.h"
#include <iostream>
#include <fstream>
#include "THStack.h"
#include "TMath.h"

using namespace std;

void plot_energy__volume_() {

  gStyle->SetOptStat(0);
  gStyle->SetOptTitle(1);


  TFile* f1;
  TTree* t1;
  char *filename;

  int nbins = _number_of_bins_;
  int bin_low = 0;
  int bin_high = _number_of_bins_;

 # TFile* f00 = new TFile("/projects/cuore/simulations_new/BenchmarkTestFiles/Old_BenchmarkData/TeO2Sx-pb210_g4cuore.root");
  TFile* f00 = new TFile"_old_input_file_");
  TTree* t00 = (TTree*)f00->Get("outTree");
 # TFile* f02 = new TFile("/projects/cuore/simulations_new/BenchmarkTestFiles/NTP/TeO2Sx-pb210_Test_g4cuore.root");
  TFile* f02 = new TFile("_new_input_file_")
  TTree* t02 = (TTree*)f02->Get("outTree");
  
  TH1F* old_Mall = new TH1F("old_Mall", "old_Mall", nbins, bin_low, bin_high);
  TH1F* old_M1 = new TH1F("old_M1", "old_M1", nbins, bin_low, bin_high);
  TH1F* old_M2 = new TH1F("old_M2", "old_M2", nbins, bin_low, bin_high);
  TH1F* old_Mmore2 = new TH1F("old_Mmore2", "old_Mmore2", nbins, bin_low, bin_high);
  TH1F* new_Mall = new TH1F("new_Mall", "new_Mall", nbins, bin_low, bin_high);
  TH1F* new_M1 = new TH1F("new_M1", "new_M1", nbins, bin_low, bin_high);
  TH1F* new_M2 = new TH1F("new_M2", "new_M2", nbins, bin_low, bin_high);
  TH1F* new_Mmore2 = new TH1F("new_Mmore2", "new_Mmore2", nbins, bin_low, bin_high);

  TH1F* residuals_Mall = new TH1F("residuals_Mall", "residuals_Mall", nbins, bin_low, bin_high);
  TH1F* residuals_M1 = new TH1F("residuals_M1", "residuals_M1", nbins, bin_low, bin_high);
  TH1F* residuals_M2 = new TH1F("residuals_M2", "residuals_M2", nbins, bin_low, bin_high);
  TH1F* residuals_Mmore2 = new TH1F("residuals_Mmore2", "residuals_Mmore2", nbins, bin_low, bin_high);


  TCut M1 = "Multiplicity == 1";
  TCut M2 = "Multiplicity == 2";
  TCut Mmore2 = "Multiplicity > 2";
  
  t00->Draw("Ener1 >> old_Mall");
  t00->Draw("Ener1 >> old_M1", M1);
  t00->Draw("Ener1 >> old_M2", M2);
  t00->Draw("Ener1 >> old_Mmore2", Mmore2);
  t02->Draw("Ener1 >> new_Mall");
  t02->Draw("Ener1 >> new_M1", M1);
  t02->Draw("Ener1 >> new_M2", M2);
  t02->Draw("Ener1 >> new_Mmore2", Mmore2);

  double integral_old = old_Mall->GetEntries();
  double integral_old_error = sqrt(integral_old);
  
  double integral_new = new_Mall->GetEntries();
  double integral_new_error = sqrt(integral_new);
  double normalization_Mall = integral_old / integral_new;
  double normalization_Mall_error = normalization_Mall * sqrt(pow((integral_old_error / integral_old), 2) + pow((integral_new_error / integral_new), 2));
  
  cout << "old integral_Mall: " << integral_old << " +- " << integral_old_error << endl;
  cout << "new integral_Mall: " << integral_new << " +- " << integral_new_error << endl;
  cout << "normalization_Mall: " << normalization_Mall << " +- " << normalization_Mall_error << endl;

  //normalization = 1;

  double integral_old = old_M1->GetEntries();
  double integral_old_error = sqrt(integral_old);
  
  double integral_new = new_M1->GetEntries();
  double integral_new_error = sqrt(integral_new);
  double normalization_M1 = integral_old / integral_new;
  double normalization_M1_error = normalization_M1 * sqrt(pow((integral_old_error / integral_old), 2) + pow((integral_new_error / integral_new), 2));
  
  cout << "old integral_M1: " << integral_old << " +- " << integral_old_error << endl;
  cout << "new integral_M1: " << integral_new << " +- " << integral_new_error << endl;
  cout << "normalization_M1: " << normalization_M1 << " +- " << normalization_M1_error << endl;

  double integral_old = old_M2->GetEntries();
  double integral_old_error = sqrt(integral_old);
  
  double integral_new = new_M2->GetEntries();
  double integral_new_error = sqrt(integral_new);
  double normalization_M2 = integral_old / integral_new;
  double normalization_M2_error = normalization_M2 * sqrt(pow((integral_old_error / integral_old), 2) + pow((integral_new_error / integral_new), 2));
  
  cout << "old integral_M2: " << integral_old << " +- " << integral_old_error << endl;
  cout << "new integral_M2: " << integral_new << " +- " << integral_new_error << endl;
  cout << "normalization_M2: " << normalization_M2 << " +- " << normalization_M2_error << endl;


  double integral_old = old_Mmore2->GetEntries();
  double integral_old_error = sqrt(integral_old);
  
  double integral_new = new_Mmore2->GetEntries();
  double integral_new_error = sqrt(integral_new);
  double normalization_Mmore2 = integral_old / integral_new;
  double normalization_Mmore2_error = normalization_Mmore2 * sqrt(pow((integral_old_error / integral_old), 2) + pow((integral_new_error / integral_new), 2));
  
  cout << "old integral_Mmore2: " << integral_old << " +- " << integral_old_error << endl;
  cout << "new integral_Mmore2: " << integral_new << " +- " << integral_new_error << endl;
  cout << "normalization_Mmore2: " << normalization_Mmore2 << " +- " << normalization_Mmore2_error << endl;

  
  new_Mall->Scale(normalization_Mall);
  new_M1->Scale(normalization_M1);
  new_M2->Scale(normalization_M2);
  new_Mmore2->Scale(normalization_Mmore2);
  
  old_Mall->SetLineColor(kBlack);
  new_Mall->SetLineColor(kRed);
  old_M1->SetLineColor(kBlack);
  new_M1->SetLineColor(kRed);
  old_M2->SetLineColor(kBlack);
  new_M2->SetLineColor(kRed);
  old_Mmore2->SetLineColor(kBlack);
  new_Mmore2->SetLineColor(kRed);


  leg_Mall = new TLegend(0.67, 0.67, 0.88, 0.88);
  leg_Mall->AddEntry(old_Mall, "Old", "l");
  leg_Mall->AddEntry(new_Mall, "New", "l");

  leg_M1 = new TLegend(0.67, 0.67, 0.88, 0.88);
  leg_M1->AddEntry(old_M1, "Old", "l");
  leg_M1->AddEntry(new_M1, "New", "l");

  leg_M2 = new TLegend(0.67, 0.67, 0.88, 0.88);
  leg_M2->AddEntry(old_M2, "Old", "l");
  leg_M2->AddEntry(new_M2, "New", "l");

  leg_Mmore2 = new TLegend(0.67, 0.67, 0.88, 0.88);
  leg_Mmore2->AddEntry(old_Mmore2, "Old", "l");
  leg_Mmore2->AddEntry(new_Mmore2, "New", "l");

  TCanvas* c2 = new TCanvas("c2", "c2", 1200, 800);
  c2->cd();
  TPad *pad1c2 = new TPad("pad1c2", "pad1c2", 0, 0.33, 1, 1);
  TPad *pad2c2 = new TPad("pad2c2", "pad2c2", 0, 0, 1, 0.33);
  pad1c2->SetBottomMargin(0.00001);
  pad1c2->SetBorderMode(0);
  pad1c2->SetLogy();
  pad2c2->SetTopMargin(0.00001);
  pad2c2->SetBottomMargin(0.2);
  pad2c2->SetBorderMode(0);
  pad1c2->Draw();
  pad2c2->Draw();
  pad1c2->cd();

  old_Mall->Draw();
  new_Mall->Draw("SAME");

  leg_Mall->Draw();

  old_Mall->SetTitle("Full Spectrum");
  old_Mall->GetXaxis()->SetLabelFont(63);
  old_Mall->GetXaxis()->SetLabelSize(16);
  old_Mall->GetXaxis()->SetTitle("Energy [keV]");
  old_Mall->GetXaxis()->SetTitleFont(63);
  old_Mall->GetXaxis()->SetTitleSize(16);
  old_Mall->GetYaxis()->SetTitle("Counts / 1 keV");
  old_Mall->GetYaxis()->SetTitleFont(63);
  old_Mall->GetYaxis()->SetTitleSize(16);
  old_Mall->GetYaxis()->SetTitleOffset(1);
  old_Mall->GetYaxis()->SetLabelFont(63);
  old_Mall->GetYaxis()->SetLabelSize(16);

  pad2c2->cd();
  residuals_Mall->SetTitle("");
  residuals_Mall->GetXaxis()->SetLabelFont(63);
  residuals_Mall->GetXaxis()->SetLabelSize(16);
  residuals_Mall->GetXaxis()->SetTitle("Energy [keV]");
  residuals_Mall->GetXaxis()->SetTitleFont(63);
  residuals_Mall->GetXaxis()->SetTitleSize(16);
  residuals_Mall->GetXaxis()->SetTitleOffset(3);
  residuals_Mall->GetYaxis()->SetTitle("((New - Old) / Old) / 1 keV");
  residuals_Mall->GetYaxis()->SetTitleFont(63);
  residuals_Mall->GetYaxis()->SetTitleSize(16);
  residuals_Mall->GetYaxis()->SetTitleOffset(1);
  residuals_Mall->GetYaxis()->SetLabelFont(63);
  residuals_Mall->GetYaxis()->SetLabelSize(16);

  for (Int_t i = 1; i <= nbins; i++) {
    if (old_Mall->GetBinContent(i) != 0)
      {
	Double_t diff = (new_Mall->GetBinContent(i) - old_Mall->GetBinContent(i)) / old_Mall->GetBinContent(i);
	Double_t differr = TMath::Sqrt(TMath::Power(new_Mall->GetBinError(i),2) + TMath::Power(new_Mall->GetBinError(i),2));
      }
    else 
      {
	Double_t diff = new_Mall->GetBinContent(i);
	Double_t differr = new_Mall->GetBinError(i);
      }
    residuals_Mall->SetBinContent(i, diff);
    //    residuals_Mall->SetBinError(i, differr);
}

  residuals_Mall->Draw("P");

  TCanvas* c3 = new TCanvas("c3", "c3", 1200, 800);
  c3->cd();
  TPad *pad1c3 = new TPad("pad1c3", "pad1c3", 0, 0.33, 1, 1);
  TPad *pad2c3 = new TPad("pad2c3", "pad2c3", 0, 0, 1, 0.33);
  pad1c3->SetBottomMargin(0.00001);
  pad1c3->SetBorderMode(0);
  pad1c3->SetLogy();
  pad2c3->SetTopMargin(0.00001);
  pad2c3->SetBottomMargin(0.2);
  pad2c3->SetBorderMode(0);
  pad1c3->Draw();
  pad2c3->Draw();
  pad1c3->cd();

  old_M1->Draw();
  new_M1->Draw("SAME");

  leg_M1->Draw();

  old_M1->SetTitle("M1 Spectrum");
  old_M1->GetXaxis()->SetLabelFont(63);
  old_M1->GetXaxis()->SetLabelSize(16);
  old_M1->GetXaxis()->SetTitle("Energy [keV]");
  old_M1->GetXaxis()->SetTitleFont(63);
  old_M1->GetXaxis()->SetTitleSize(16);
  old_M1->GetYaxis()->SetTitle("Counts / 1 keV");
  old_M1->GetYaxis()->SetTitleFont(63);
  old_M1->GetYaxis()->SetTitleSize(16);
  old_M1->GetYaxis()->SetTitleOffset(1);
  old_M1->GetYaxis()->SetLabelFont(63);
  old_M1->GetYaxis()->SetLabelSize(16);

  pad2c3->cd();
  residuals_M1->SetTitle("");
  residuals_M1->GetXaxis()->SetLabelFont(63);
  residuals_M1->GetXaxis()->SetLabelSize(16);
  residuals_M1->GetXaxis()->SetTitle("Energy [keV]");
  residuals_M1->GetXaxis()->SetTitleFont(63);
  residuals_M1->GetXaxis()->SetTitleSize(16);
  residuals_M1->GetXaxis()->SetTitleOffset(3);
  residuals_M1->GetYaxis()->SetTitle("((New - Old) / Old) / 1 keV");
  residuals_M1->GetYaxis()->SetTitleFont(63);
  residuals_M1->GetYaxis()->SetTitleSize(16);
  residuals_M1->GetYaxis()->SetTitleOffset(1);
  residuals_M1->GetYaxis()->SetLabelFont(63);
  residuals_M1->GetYaxis()->SetLabelSize(16);

  for (Int_t i = 1; i <= nbins; i++) {
    if (old_M1->GetBinContent(i) != 0)
      {
	Double_t diff = (new_M1->GetBinContent(i) - old_M1->GetBinContent(i)) / old_M1->GetBinContent(i);
	Double_t differr = TMath::Sqrt(TMath::Power(new_M1->GetBinError(i),2) + TMath::Power(new_M1->GetBinError(i),2));
      }
    else 
      {
	Double_t diff = new_M1->GetBinContent(i);
	Double_t differr = new_M1->GetBinError(i);
      }
    residuals_M1->SetBinContent(i, diff);
    //    residuals_M1->SetBinError(i, differr);
}

  residuals_M1->Draw("P");

 
  TCanvas* c4 = new TCanvas("c4", "c4", 1200, 800);
  c4->cd();
  TPad *pad1c4 = new TPad("pad1c4", "pad1c4", 0, 0.33, 1, 1);
  TPad *pad2c4 = new TPad("pad2c4", "pad2c4", 0, 0, 1, 0.33);
  pad1c4->SetBottomMargin(0.00001);
  pad1c4->SetBorderMode(0);
  pad1c4->SetLogy();
  pad2c4->SetTopMargin(0.00001);
  pad2c4->SetBottomMargin(0.2);
  pad2c4->SetBorderMode(0);
  pad1c4->Draw();
  pad2c4->Draw();
  pad1c4->cd();

  old_M2->Draw();
  new_M2->Draw("SAME");

  leg_M2->Draw();

  old_M2->SetTitle("M2 Spectrum");
  old_M2->GetXaxis()->SetLabelFont(63);
  old_M2->GetXaxis()->SetLabelSize(16);
  old_M2->GetXaxis()->SetTitle("Energy [keV]");
  old_M2->GetXaxis()->SetTitleFont(63);
  old_M2->GetXaxis()->SetTitleSize(16);
  old_M2->GetYaxis()->SetTitle("Counts / 1 keV");
  old_M2->GetYaxis()->SetTitleFont(63);
  old_M2->GetYaxis()->SetTitleSize(16);
  old_M2->GetYaxis()->SetTitleOffset(1);
  old_M2->GetYaxis()->SetLabelFont(63);
  old_M2->GetYaxis()->SetLabelSize(16);

  pad2c4->cd();
  residuals_M2->SetTitle("");
  residuals_M2->GetXaxis()->SetLabelFont(63);
  residuals_M2->GetXaxis()->SetLabelSize(16);
  residuals_M2->GetXaxis()->SetTitle("Energy [keV]");
  residuals_M2->GetXaxis()->SetTitleFont(63);
  residuals_M2->GetXaxis()->SetTitleSize(16);
  residuals_M2->GetXaxis()->SetTitleOffset(3);
  residuals_M2->GetYaxis()->SetTitle("((New - Old) / Old) / 1 keV");
  residuals_M2->GetYaxis()->SetTitleFont(63);
  residuals_M2->GetYaxis()->SetTitleSize(16);
  residuals_M2->GetYaxis()->SetTitleOffset(1);
  residuals_M2->GetYaxis()->SetLabelFont(63);
  residuals_M2->GetYaxis()->SetLabelSize(16);

  for (Int_t i = 1; i <= nbins; i++) {
    if (old_M2->GetBinContent(i) != 0)
      {
	Double_t diff = (new_M2->GetBinContent(i) - old_M2->GetBinContent(i)) / old_M2->GetBinContent(i);
	Double_t differr = TMath::Sqrt(TMath::Power(new_M2->GetBinError(i),2) + TMath::Power(new_M2->GetBinError(i),2));
      }
    else 
      {
	Double_t diff = new_M2->GetBinContent(i);
	Double_t differr = new_M2->GetBinError(i);
      }
    residuals_M2->SetBinContent(i, diff);
    //    residuals_M2->SetBinError(i, differr);
}

  residuals_M2->Draw("P");


  TCanvas* c5 = new TCanvas("c5", "c5", 1200, 800);
  c5->cd();
  TPad *pad1c5 = new TPad("pad1c5", "pad1c5", 0, 0.33, 1, 1);
  TPad *pad2c5 = new TPad("pad2c5", "pad2c5", 0, 0, 1, 0.33);
  pad1c5->SetBottomMargin(0.00001);
  pad1c5->SetBorderMode(0);
  pad1c5->SetLogy();
  pad2c5->SetTopMargin(0.00001);
  pad2c5->SetBottomMargin(0.2);
  pad2c5->SetBorderMode(0);
  pad1c5->Draw();
  pad2c5->Draw();
  pad1c5->cd();

  old_Mmore2->Draw();
  new_Mmore2->Draw("SAME");

  leg_Mmore2->Draw();

  old_Mmore2->SetTitle("M > 2 Spectrum");
  old_Mmore2->GetXaxis()->SetLabelFont(63);
  old_Mmore2->GetXaxis()->SetLabelSize(16);
  old_Mmore2->GetXaxis()->SetTitle("Energy [keV]");
  old_Mmore2->GetXaxis()->SetTitleFont(63);
  old_Mmore2->GetXaxis()->SetTitleSize(16);
  old_Mmore2->GetYaxis()->SetTitle("Counts / 1 keV");
  old_Mmore2->GetYaxis()->SetTitleFont(63);
  old_Mmore2->GetYaxis()->SetTitleSize(16);
  old_Mmore2->GetYaxis()->SetTitleOffset(1);
  old_Mmore2->GetYaxis()->SetLabelFont(63);
  old_Mmore2->GetYaxis()->SetLabelSize(16);

  pad2c5->cd();
  residuals_Mmore2->SetTitle("");
  residuals_Mmore2->GetXaxis()->SetLabelFont(63);
  residuals_Mmore2->GetXaxis()->SetLabelSize(16);
  residuals_Mmore2->GetXaxis()->SetTitle("Energy [keV]");
  residuals_Mmore2->GetXaxis()->SetTitleFont(63);
  residuals_Mmore2->GetXaxis()->SetTitleSize(16);
  residuals_Mmore2->GetXaxis()->SetTitleOffset(3);
  residuals_Mmore2->GetYaxis()->SetTitle("((New - Old) / Old) / 1 keV");
  residuals_Mmore2->GetYaxis()->SetTitleFont(63);
  residuals_Mmore2->GetYaxis()->SetTitleSize(16);
  residuals_Mmore2->GetYaxis()->SetTitleOffset(1);
  residuals_Mmore2->GetYaxis()->SetLabelFont(63);
  residuals_Mmore2->GetYaxis()->SetLabelSize(16);

  for (Int_t i = 1; i <= nbins; i++) {
    if (old_Mmore2->GetBinContent(i) != 0)
      {
	Double_t diff = (new_Mmore2->GetBinContent(i) - old_Mmore2->GetBinContent(i)) / old_Mmore2->GetBinContent(i);
	Double_t differr = TMath::Sqrt(TMath::Power(new_Mmore2->GetBinError(i),2) + TMath::Power(new_Mmore2->GetBinError(i),2));
      }
    else 
      {
	Double_t diff = new_Mmore2->GetBinContent(i);
	Double_t differr = new_Mmore2->GetBinError(i);
      }
    residuals_Mmore2->SetBinContent(i, diff);
    //    residuals_Mmore2->SetBinError(i, differr);
}

  residuals_Mmore2->Draw("P");

  
	// Save all the files
	c2->SaveAs("_plot_output_location__volume__Mall.pdf");
	c2->SaveAs("_plot_output_location__volume__Mall.C");
	c3->SaveAs("_plot_output_location__volume__M1.pdf");
	c3->SaveAs("_plot_output_location__volume__M1.C");
	c4->SaveAs("_plot_output_location__volume__M2.pdf");
	c4->SaveAs("_plot_output_location__volume__M2.C");
	c5->SaveAs("_plot_output_location__volume__Mmore2.pdf");
	c5->SaveAs("_plot_output_location__volume__Mmore2.C");
	
	// Write the output file
	ofstream OutFile;
	OutFile.open("Ratios.dat");
	OutFile << normalization_Mall << "\t" << normalization_Mall_error;
	OutFile << normalization_M1 << "\t" << normalization_M1_error;
	OutFile << normalization_M2 << "\t" << normalization_M1_error;
	OutFile << normalization_Mmore2 << "\t" << normalization_M2_error;
	OutFile.close();
}
