program xc12;
uses atari, b_dl, fonts, pmlib;

//game uses antic mode 4 (5 color char mode)

const
	dlist = $5000;		//$8000
	scanLineWid: byte = 48;
	ramOffset: byte = 44;
var 
	{$I tilesSet.txt}
	{$I levels.txt}
	hscroll:byte = 3;
	levelPos: word = 0;
	genLine: byte = 0;
	vmem: word = $5100;			//$8100
	
	clr1: array [0..2] of byte;// absolute $8118;
	clr2: array [0..2] of byte;// absolute $811D;
	
	col1: byte absolute 53271;
	col2: byte absolute 53273;
	
	dliNum: byte = 0;
	
	//joystick section
	stick0: byte absolute $278;
	{15 - neutral
	* 14 - up
	* 13 - down
	* 11 - left
	* 7 - right
	* 10 - left up
	* 9 - left down
	* 6 - right up
	* 5 - right down}
	
	xOffset: array [0..15] of smallint = (0,0,0,0,0,1,1,1,0,-2,-2,-2,0,0,0,0);
	yOffset: array [0..15] of smallint = (0,0,0,0,0,1,-1,0,0,1,-1,0,0,1,-1,0);

	stickVal: byte;

	
procedure generateDL;
begin
	DL_Init(dlist);
	DL_Push(DL_BLANK8);
	DL_Push(DL_BLANK8);
	DL_Push(DL_BLANK8);
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL + DL_LMS, vmem); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,2); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,7); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,3); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL+ DL_DLI); 
	DL_Push(DL_MODE_40x24T5 + DL_HSCROLL,5); 
	DL_Push(DL_JVB, dlist); // jump back
	DL_Start;
end;



procedure Dli; interrupt;
begin
	asm { phr };
//	wsync:=1;
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
			genLine:=1;				//allow adding new line of level in main loop
			inc(vmem);
			//3x8 blankllines are added, thus 4th line is poked)
			DL_PokeW(4, vmem); 		// set new memory offset 
     
		end; 
		hscrol := hscroll; // set hscroll
		dec(hscroll);
end;

procedure addLine;
begin
	writeTile();
	inc(levelPos);
	genLine:=0;

end;

procedure movePlayer; overload;
begin
	stickVal:=stick0;
	if stickVal<15 then pmlib.movePlayer(xOffset[stickVal],yOffset[stickVal]);
end;

procedure vbl; interrupt;
begin
	movePlayer;
	if levelPos=280 then levelPos:=0;
	scroll;
	if p0pf<>0 then begin
		pmlib.movePlayer(-5,0);
		HITCLR:=0;					//hit clear - clears collision registers
	end;
	asm { jmp $E462 };
end;



begin
	
	//set colors
	Poke(708,148);//148
	Poke(709,34);	
	Poke(710,152);	//-> inverse, 152
	Poke(711,22);	//inverse
	Poke(712,0);	//bkg
	
	clr1[0]:=8;		//8
	clr1[1]:=34;
	clr1[2]:=8;		//8
	
	clr2[0]:=4;	//144	//4
	clr2[1]:=22;
	clr2[2]:=4;		//4
	
	
	generateDL;
	LoadCharSet;

	Poke(54286,192); 		//enable DLI
	SetIntVec(iDLI, @Dli);	//set dli vector
	SetIntVec(iVBL, @vbl);
	
	pmlib.loadPlayers;
	
	repeat
		if genLine=1 then addLine;
	until false;
end.

