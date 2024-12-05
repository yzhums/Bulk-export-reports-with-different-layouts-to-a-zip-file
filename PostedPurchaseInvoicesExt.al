pageextension 50116 PostedPurchaseInvoicesExt extends "Posted Purchase Invoices"
{
    actions
    {
        addafter("&Invoice")
        {
            action(DownloadSelectedInvoicesAsPDF)
            {
                ApplicationArea = All;
                Caption = 'Download Selected Invoices as PDF';
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReportSelection: Record "Report Selections";
                    PurchInvHeader: Record "Purch. Inv. Header";
                    PurchInvHeader2: Record "Purch. Inv. Header";
                    TempReportSelections: Record "Report Selections" temporary;
                    TempBlob: Codeunit "Temp Blob";
                    RecordVariant: Variant;
                    ZipFileName: Text[50];
                    PdfFileName: Text[50];
                    DataCompression: Codeunit "Data Compression";
                    InS: InStream;
                    OutS: OutStream;
                begin
                    ZipFileName := 'PurchaseInvoice_' + Format(CurrentDateTime) + '.zip';
                    DataCompression.CreateZipArchive();
                    PurchInvHeader.Reset();
                    CurrPage.SetSelectionFilter(PurchInvHeader);
                    if PurchInvHeader.FindSet() then
                        repeat
                            PurchInvHeader2.Get(PurchInvHeader."No.");
                            PurchInvHeader2.SetRecFilter();
                            ReportSelection.FindReportUsageForVend(Enum::"Report Selection Usage"::"P.Invoice", PurchInvHeader2."Buy-from Vendor No.", TempReportSelections);
                            Clear(TempBlob);
                            TempReportSelections.SaveReportAsPDFInTempBlob(TempBlob, TempReportSelections."Report ID", PurchInvHeader2,
                                                                            TempReportSelections."Custom Report Layout Code", Enum::"Report Selection Usage"::"P.Invoice");
                            TempBlob.CreateInStream(InS);
                            PdfFileName := Format(PurchInvHeader2."No." + '.pdf');
                            DataCompression.AddEntry(InS, PdfFileName);
                        until PurchInvHeader.Next() = 0;
                    TempBlob.CreateOutStream(OutS);
                    DataCompression.SaveZipArchive(OutS);
                    TempBlob.CreateInStream(InS);
                    DownloadFromStream(InS, '', '', '', ZipFileName);
                end;
            }
        }
    }
}
