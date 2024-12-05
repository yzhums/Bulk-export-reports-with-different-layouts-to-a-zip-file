pageextension 50115 PostedSalesInvoicesExt extends "Posted Sales Invoices"
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
                    SalesInvHeader: Record "Sales Invoice Header";
                    SalesInvHeader2: Record "Sales Invoice Header";
                    TempReportSelections: Record "Report Selections" temporary;
                    TempBlob: Codeunit "Temp Blob";
                    RecordVariant: Variant;
                    ZipFileName: Text[50];
                    PdfFileName: Text[50];
                    DataCompression: Codeunit "Data Compression";
                    InS: InStream;
                    OutS: OutStream;
                begin
                    ZipFileName := 'SalesInvoice_' + Format(CurrentDateTime) + '.zip';
                    DataCompression.CreateZipArchive();
                    SalesInvHeader.Reset();
                    CurrPage.SetSelectionFilter(SalesInvHeader);
                    if SalesInvHeader.FindSet() then
                        repeat
                            SalesInvHeader2.Get(SalesInvHeader."No.");
                            SalesInvHeader2.SetRecFilter();
                            ReportSelection.FindReportUsageForCust(Enum::"Report Selection Usage"::"S.Invoice", SalesInvHeader2."Bill-to Customer No.", TempReportSelections);
                            Clear(TempBlob);
                            TempReportSelections.SaveReportAsPDFInTempBlob(TempBlob, TempReportSelections."Report ID", SalesInvHeader2,
                                                                            TempReportSelections."Custom Report Layout Code", Enum::"Report Selection Usage"::"S.Invoice");
                            TempBlob.CreateInStream(InS);
                            PdfFileName := Format(SalesInvHeader2."No." + '.pdf');
                            DataCompression.AddEntry(InS, PdfFileName);
                        until SalesInvHeader.Next() = 0;
                    TempBlob.CreateOutStream(OutS);
                    DataCompression.SaveZipArchive(OutS);
                    TempBlob.CreateInStream(InS);
                    DownloadFromStream(InS, '', '', '', ZipFileName);
                end;
            }
        }
    }
}
