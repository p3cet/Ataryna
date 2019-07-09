program xc12;
uses atari, b_dl, fonts;

//game uses antic mode 4 (5 color char mode)

const
	dlist = $5000;		//$8000
	scanLineWid: byte = 48;
	ramOffset: byte = 44;
var 
	{$I tilesSet.txt}
	{$I levels.txt}
	s:string = '01234567890123456789012345678901234567890123456789'~;
	hscroll:byte = 3;
    loop: byte;
	levelPos: byte = 0;
	syncVBL: byte = 0;
	vmem: word = $5100;			//$8100
	
	clr1: array [0..2] of byte;// absolute $8118;
	clr2: array [0..2] of byte;// absolute $811D;
	
	col1: byte absolute 53271;
	col2: byte absolute 53273;
	
	dliNum: byte = 0;


	
procedure generateDL;
begin
	DL_Init(dlist);
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL + DL_LMS, vmem); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,7); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,9); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,4); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,5); 
	DL_Push(DL_JVB, dlist); // jump back
	DL_Start;
end;



procedure Dli; interrupt;
begin
	asm { phr };
//	Poke(54282,1);		//wsync
	col1:=clr1[dliNum];
	col2:=clr2[dliNum];
	inc(dliNum);
	if dliNum=3 then dliNum:=0;
	asm { plr };
end;



procedure writeTile();
var i: byte;
	scanLine: word;
	tileIndex: byte;
begin
	scanLine:=vmem+ramOffset;

	//area1
	tileIndex:=level1_1[levelPos];
	for i:=0 to 3 do
		begin
			Poke(scanLine,tiles[tileIndex,i]);
			scanLine:=scanLine+scanLineWid;
		end;
	//area2
	tileIndex:=level1_2[levelPos];
	for i:=0 to 3 do
	begin
		Poke(scanLine,tiles[tileIndex,i]);
		scanLine:=scanLine+scanLineWid;
	end;
	//area3
	tileIndex:=level1_3[levelPos];
	for i:=0 to 3 do
	begin
		Poke(scanLine,tiles[tileIndex,i]);
		scanLine:=scanLine+scanLineWid;
	end;
	//area4
	tileIndex:=level1_4[levelPos];
	for i:=0 to 3 do
	begin
		Poke(scanLine,tiles[tileIndex,i]);
		scanLine:=scanLine+scanLineWid;
	end;


end;

procedure scroll;
begin
	if hscroll = $ff then begin 	// $ff is one below zero
			hscroll := 3;
			syncVBL:=1;				//allow adding new line of level in main loop
			inc(vmem);
			//TODO: change 1? add blanklines?
			DL_PokeW(1, vmem); 		// set new memory offset 
     
		end; 
		hscrol := hscroll; // set hscroll
		dec(hscroll);
end;

procedure addLine;
begin
	writeTile();
	inc(levelPos);
	syncVBL:=0;

end;

procedure vbl; interrupt;
begin
	if levelPos<80 then begin
		scroll;
	end
	else levelPos:=0;
	asm { jmp $E462 };
end;


begin
	
	//set colors
	Poke(708,148);//148
	Poke(709,8);	
	Poke(710,152);	//-> inverse, 152
	Poke(711,4);	//inverse
	Poke(712,0);	//bkg
	
	clr1[0]:=34;
	clr1[1]:=4;
	clr1[2]:=34;
	
	clr2[0]:=22;
	clr2[1]:=8;
	clr2[2]:=22;

	
	
	generateDL;
	LoadCharSet;

	Poke(54286,192); 			//enable DLI
	SetIntVec(iDLI, @Dli);	//set dli vector
	SetIntVec(iVBL, @vbl);
	
	move(s[1],pointer(vmem+4),sizeOf(s)); // copy text to vram
	move(s[1],pointer(vmem+52),sizeOf(s)); // copy text to vram
	move(s[1],pointer(vmem+100),sizeOf(s)); // copy text to vram
  
	repeat
	if syncVBL=1 then addLine;
	until false;
end.

