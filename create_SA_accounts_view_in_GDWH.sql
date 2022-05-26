
-- create analog of the Midas.Accounts (SAS) table  

create table SA_Midas_Accounts as                      
      (select 
            (BRCA || CNUM || ACOD || ACSQ) as Accountn,
            RECI as RecI,
            Cnum as Customer,
            CCY as Currency,
            ACOD as Acode,     -- put(ACOD, z4.) as Acode,
            ACSQ as Aseq,   -- put(ACSQ, z2.) as Aseq, 
            FCNO as Fseq,    -- put(FCNO, z2.) as Fseq,
            BRCA as Branch,
            ATYP as Atype,
            STYP as  Stype,
            DACO AS Dopened,
            DACC as Dclosed,
            ACNO as  RetailN,
            ANAM as Name_,         
            ODED as OLEDate,    -- %dtm2s(ODED, var = OLEDate) as OLEDate,
            MINB as MinBal,
            DRIS as Dinterest,      
            CRIS as Cinterest,
            CHTP as ChangeType,
            DRIC as DrIntCalcBasis,
            DRIF as DrIntFreq,
            CRIC as CrIntCalcBasis,
            CRIF as CrIntFreq,
            STFQ as StmFreq,
            PRFC as Profit_Centre,
            LDBL as Lsum,           -- LDBL / divider
            CLBL as Csum,           -- CLBL / divider
            DIIE as DInterestSum,   --  DIIE / divider
            CIIE as CInterestSum,   -- IIE / divider    
            DRIB as DBaseType,             -- put(ifn(DRIB = ., 0, DRIB), z2.) as DBaseType,
            CRIB as CBaseType,            -- put(ifn(CRIB = ., 0, CRIB), z2.)  as  CBaseType,
            FACT as Facility,              -- put(FACT, z3.) as Facility,      
            
            NCID as CCapDate,   -- %dtm2s(NCID, var = CCapDate) as CCapDate,
            LCD  as  LCDate,    -- %dtm2s(LCD,  var = LCDate)  as  LCDate,
            NDID as DCapDate,    -- %dtm2s(NDID, var = DCapDate) as DCapDate,      
            -- h_divider.find(key:currency) as RC,
      
            ODLN as OverLine,   --if ODLN = 0 then OverLine = '.' else OverLine = ODLN,
            case 
              when trim(translate (anam,'0123456789-,.', ' ')) is null 
              then anam
            end as CBAccount          -- 0 = verify( Name, '0123456789' ) then CBAccount = Name ,
            
            /*
            ifc(upcase(ACST)  = 'C', 'N', 'Y'); as Opened,,
            ifc(char(RETB, 1) = '1', 'Y', 'N') as REFER_ALL_DEBITS
            ifc(char(RETB, 2) = '1', 'Y', 'N') as REFER_ALL_CREDITS,
            ifc(char(RETB, 3) = '1', 'Y', 'N') as DEBBLCK,
            ifc(char(RETB, 4) = '1', 'Y', 'N') as CRBLCK,
            ifc(char(RETB, 5) = '1', 'Y', 'N') as INACTIVE  */
      from MIDASPLUS14_LANDING.ACCNTAB                            
      where load_date = trunc(sysdate -1) 
    );


/* select case 
            when trim(translate (anam,'0123456789-,.', ' ')) is null                    -- (select anam from MIDASPLUS14_LANDING.ACCNTAB where regexp_like(anam,'^[[:digit:]]+$')) 
            then anam
      end as CBAccount
      from MIDASPLUS14_LANDING.ACCNTAB                            
      where load_date = trunc(sysdate -1) */


______________________________________________________________________________________________

-- create analog of Midas.Reiacd (SAS) table

create table SA_Midas_Reiacd as 
      (select
              (brca||cnum||ccy||acod||acsq) as accountn,                -- 'Account number'
              cnum as customer,               		
              ccy as currency, 
              acod as acode,          -- acode=put(acod,z4.)           'Account code'
              acsq as eq,           -- aseq=put(acsq,z2.)            'Account sequence'   		
              dict as DiCalcType,     -- DiCalcType=put(dict,z2.)      'Debit interest calculation type'	          		
              dcst as DiCalcSubType,  -- DiCalcSubType=put(dcst,z5.)    'Debit interest calculation sub-type'		         		
              cict as CiCalcType,     -- CiCalcType=put(cict,z2.)        'Credit interest calculation type'		       		
              ccst as CiCalcSubType,  -- CiCalcSubType=put(ccst,z5.)      'Credit interest calculation sub-type'		       		
              brca as branch,
              dacp as RetailN_CurrAcc                                   --'RetailN текущего счета, который прив€зан к счету овердрафта'	
      from MIDASPLUS14_LANDING.REIACD                                   
      where load_date = trunc(sysdate -1)
    );
    

___________________________________________________________________________________________________________________________________________

-- create analog of refer.ACCOUNTS_VIEW (SAS) table

create table SA_ACCOUNTS_VIEW as 
      ( select
          SA_Midas_Accounts.AccountN, 
          RecI, 
          SA_Midas_Accounts.Customer, 
          SA_Midas_Accounts.Currency, 
          SA_Midas_Accounts.ACode, 
          ASeq, 
          SA_Midas_Accounts.Branch, 
          AType, 
          SType,
          DOpened, 
          DClosed, 
          CBAccount,
          RetailN,
          Name_,
          OverLine,
          OLEDate,
          MinBal,
          DBaseType,
          DInterest,
          DCapDate,
          CBaseType,
          CInterest,
          CCapDate,
          StmFreq,
          LCDate,
          ChangeType,
          DrIntCalcBasis,
          DrIntFreq,
          CrIntCalcBasis,
          CrIntFreq,
          Facility,
          Profit_Centre,
          DICALCTYPE,      -- 'Debit interest calculation type',
          CICALCTYPE,      -- 'Credit interest calculation type'
          DICALCSUBTYPE,   -- 'Debit interest calculation sub-type'
          CICALCSUBTYPE   -- 'Credit interest calculation sub-typeС
    
      from SA_Midas_Accounts 
      left join SA_Midas_Reiacd 
           on SA_Midas_Accounts.AccountN = SA_Midas_Reiacd.AccountN
    );



