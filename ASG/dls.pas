unit dls;

interface
uses atari, b_dl;

const
	dlist: word = $5000;
	vmem: word = $5100;
	vmem2: word = $6000;
	dlistTitle: word =$7000;	
	vmemTitle: word = $7100;
	
procedure dlLvl1;
procedure dlTitle;

implementation
	procedure dlLvl1;
	begin
		DL_Init(dlist);
		DL_Push(DL_BLANK8);
		DL_Push(DL_BLANK8);
		DL_Push(DL_BLANK8);
		DL_Push(DL_MODE_320x192G2 + DL_LMS, vmem); 
		DL_Push(DL_MODE_320x192G2,10); 
		DL_Push(DL_MODE_320x192G2+ DL_DLI); 
		DL_Push(DL_MODE_320x192G2,10); 
		DL_Push(DL_MODE_320x192G2+ DL_DLI); 
		DL_Push(DL_MODE_320x192G2,10); 
		DL_Push(DL_MODE_320x192G2+ DL_DLI); 
		DL_Push(DL_MODE_320x192G2,70);
		DL_Push(DL_MODE_320x192G2 + DL_LMS, vmem2);
		DL_Push(DL_MODE_320x192G2,100); 
		DL_Push(DL_JVB, dlist); 
		DL_Start;
		Poke(560,lo(dlist));
		Poke(561,hi(dlist));
	end;
	
	procedure dlTitle;
	begin
		DL_Init(dlistTitle);
		DL_Push(DL_BLANK8);
		DL_Push(DL_BLANK8);
		DL_Push(DL_BLANK8);
		DL_Push(DL_MODE_40x24T2 + DL_LMS, vmemTitle); 
		DL_Push(DL_MODE_40x24T2,20); 
		DL_Push(DL_JVB, dlistTitle); 
		DL_Start;
		Poke(560,lo(dlistTitle));		//save dlist location
		Poke(561,hi(dlistTitle));
		Poke(88,lo(vmemTitle));			//and vmem location
		Poke(89,hi(vmemTitle));
	end;
end.
