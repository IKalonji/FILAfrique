export interface Token {
    country: string,
    tokenName:string,
    tokenSymbol: string,
    tokenFlag: string;
}

export const FILToken: Token[] = [
    {
        country: "Fil",
        tokenName: "Fil",
        tokenSymbol: "Fil",
        tokenFlag: "//logo.chainbit.xyz/fil"
    }
    ,{
        country: "Cameroon",
        tokenName: "CFA Franc BEAC",
        tokenSymbol: "filXAF",
        tokenFlag: "https://countryflagsapi.com/png/cameroon"
    },{
        country: "South Africa",
        tokenName: "South African Rand",
        tokenSymbol: "filZAR",
        tokenFlag: "https://countryflagsapi.com/png/south africa"
    },{
        country: "Egypt",
        tokenName: "Pound (Egypt)",
        tokenSymbol: "filEGP",
        tokenFlag: "https://countryflagsapi.com/png/egypt"
    },{
        country: "Nigeria",
        tokenName: "Naira",
        tokenSymbol: "filNGN",
        tokenFlag: "https://countryflagsapi.com/png/nigeria"
    }
]

/*
Algeria – Dinar (DZD)
Angola – Angolan Kwanza (AOA)
Benin – CFA Franc (XOF)
Botswana – Pula (BWP)
Burundi – Burundi Franc (BIF)
Burkina Faso – CFA Franc BCEAO (XOF)
Cameroon – CFA Franc BEAC (XAF)
Cape Verde – Cape Verde Escudo (CVE)
Central African Republic – CFA Franc BEAC (XAF)
Chad – CFA Franc BEAC (XAF)
Comoros – Comoros Franc (KMF)
Cote d’Ivoire – CFA Franc BCEAO (XOF)
DR Congo – Francs (CDF)
Djibouti – Djibouti Franc (DJF)
Egypt – Pound (EGP)
Equatorial Guinea – CFA Franc BEAC (XAF)
Eritrea – Eriterian Nakfa (ERN)
Ethiopia – Birr (ETB)
Gabon – CFA Franc BEAC (XAF)
Gambia – Dalasi (GMD)
Ghana – Cedi (GHS)
Guinea – Franc (GNF)
Guinea-Bissau – Guinea-Bissau Peso (GWP)
Kenya – Shillings (KES)
Lesotho – Loti (LSL)
Liberia – Dollar (LRD)
Libya – Dinar (LYD)
Madagascar – Malagasy ariary (MGA)
Malawi – Kwacha (MWK)
Mali – CFA Franc BCEAO (XOF)
Mauritania – Ouguiya (MRO)
Mauritius – Rupees (MUR)
Morocco – Dirham (MAD)
Mozambique – Metical (MZN)
Namibia – Dollar (NAD)
Niger – CFA Franc BCEAO (XOF)
Nigeria – Naira (NGN)
Republic of the Congo – Franc BEAC (XAF)
Réunion – Euro (EUR)
Rwanda – Franc (RWF)
São Tomé and Principe – Dobra (STD)
Senegal – CFA Franc BCEAO (XOF)
Seychelles – Rupees (SCR)
Sierra Leone –  Leone (SLL)
Somalia – Shillings (SOS)
South Africa – Rand (ZAR)
South Sudan – Pound (SSP)
Sudan – Pound (SDG)
Swaziland – Lilangeni (SZL)
Tanzania – Shillings (TZS)
Togo – CFA Franc BCEAO (XOF)
Tunisia – Dinar (TND)
Uganda – Shillings (UGX)
Zambia – Kwacha (ZMW)
Zimbabwe – Dollar (ZWD)
*/