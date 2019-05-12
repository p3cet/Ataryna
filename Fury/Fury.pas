program fury;


uses crt, graph, fonts, pmlib, pmg;
const offset: byte = 80;
	dliLine: byte = 9;
	dirValues: array [0..15] of byte = (0,0,0,0,0,1,1,1,0,2,2,2,0,0,0,0);


var //general variables
	{$I tilesSet.txt}
	{$I levels.txt}
    ala: byte = 0;
	go: byte =1;
	loop: byte;
	scrollCounter: byte = 0;
	levelPosCounter: byte;
	
	draw: byte =0;
	
	//display list and video
	dl: array [0..77] of byte absolute $8000;
	//vram starts at lms start
	lmsStart: word = $8150;			
	lmsOrg: array [0..23] of word absolute $8100;
	lmsTemp: word;	
	dl4: word;
	
	//joystick
	scrollDir: byte =0;
	{0 - no scroll
	* 1- scroll to the left
	* 2 - scroll to the right}
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
	

procedure generateDL;
begin
	for loop:=0 to 2 do
		dl[loop]:=112;
	
	for loop:=0 to 23 do begin
		dl[loop*3+3]:=68;
		DPoke(word(@dl)+loop*3+4,lmsStart);
		lmsOrg[loop]:=lmsStart;
		lmsStart:=lmsStart+offset;
	end;

	dl[75]:=65;
	DPoke(word(@dl)+76,word(@dl));
	Poke(word(@dl)+dliLine*3,68+128);	//insert DLI
end;

procedure Dli; interrupt;
begin
	asm { phr };
	Poke(54282,1);		//wsync
	Poke(53271,34);
	Poke(53273,22);
	asm { plr };
end;


procedure writeTile(ramOffset: byte; tileIndex: byte);
var i: byte;
begin
	for i:=0 to 19 do
		Poke(lmsOrg[i]+ramOffset,tiles[tileIndex,i]);
end;


{procedure coarseScrollLeft;
begin
		dl4:= word(@dl)+4;
		if (scrollCounter<40) then 	begin
			//coarse scroll one char
			for loop:=0 to 23 do begin
				lmsTemp:=Dpeek(dl4)+1;
				DPoke(dl4,lmsTemp);
				inc(dl4,3);
			end;
			inc(levelPosCounter);
			writeTile(scrollCounter,level1[levelPosCounter]);
			writeTile(scrollCounter+40,level1[levelPosCounter]);
			inc(scrollCounter);
		end
		else begin
			//reset all lms to start position to wrap scroll
			for loop:=0 to 23 do begin
				DPoke(dl4,lmsOrg[loop]);
				inc(dl4,3);
			end;
			scrollCounter:=0;
			levelPosCounter:=39;//todo: remove
		end;

end;
}

procedure coarseScrollLeft;
begin
		dl4:= word(@dl)+4;
		
		if (scrollCounter<40) then 	begin
			
			inc(levelPosCounter);
			writeTile(scrollCounter+40,level1[levelPosCounter]);

			//coarse scroll one char
			for loop:=0 to 23 do begin
				lmsTemp:=Dpeek(dl4)+1;
				DPoke(dl4,lmsTemp);
				inc(dl4,3);
			end;
			writeTile(scrollCounter,level1[levelPosCounter]);
			inc(scrollCounter);
			
		end
		else begin
			//reset all lms to start position to wrap scroll
			for loop:=0 to 23 do begin
				DPoke(dl4,lmsOrg[loop]);
				inc(dl4,3);
			end;
			scrollCounter:=0;
			levelPosCounter:=39;//todo: remove
		end;

end;



procedure mainLoop;

begin
	scrollDir:=dirValues[stick0];
	
	delay(0);	
	
	if (scrollDir=1) then begin
		scrollDir:=0;
		if (ala=2) then begin
			//coarseScrollLeft;
			ala:=0;
		end
		else 
			ala:=ala+1;
		//MoveP(0, 80+scrollCounter, 65);
		//MoveP(1, 88+scrollCounter, 65);
		//pmlib.swap;
	end
	else if scrollDir=2 then begin
	end;
end;

procedure incLmsEnd;
begin
	inc(levelPosCounter);
	writeTile(scrollCounter+40,level1[levelPosCounter]);
end;

procedure incLmsBegin;
begin
	writeTile(scrollCounter,level1[levelPosCounter]);
	inc(scrollCounter);
end;

procedure updateLms;
begin
	//coarse scroll one char
	for loop:=0 to 23 do begin
		lmsTemp:=Dpeek(dl4)+1;
		DPoke(dl4,lmsTemp);
		inc(dl4,3);
	end;
end;

procedure resetLms;
begin
	//reset all lms to start position to wrap scroll
	for loop:=0 to 23 do begin
		DPoke(dl4,lmsOrg[loop]);
		inc(dl4,3);
	end;
end;

procedure scrollAndUpdate;
begin
	if (draw=0) then begin
		incLmsEnd;
		draw:=1;
	end
	else begin
		updateLms;
		incLmsBegin;
		draw:=0;
	end;
end;

procedure coarseScroll;
begin
	dl4:= word(@dl)+4;

	if (scrollCounter<40) then 	begin
		scrollAndUpdate;
	end
	else begin
		resetLms;
		scrollCounter:=0;
		levelPosCounter:=39;//todo: remove
	end;
	
end;

procedure vbl; interrupt;

begin
	coarseScroll;
	asm { jmp $E462 };
end;


BEGIN
	//set colors
	Poke(708,148);
	Poke(709,8);	
	Poke(710,152);	//-> inverse
	Poke(711,4);	//inverse
	Poke(712,0);	//bkg
	
	
	generateDL;
	DPoke(560,word(@dl));

	LoadCharSet;
	loadPlayers;


		
	//load first forty tiles
	for loop:=0 to 39 do begin //todo: 40 maybe? 
		writeTile(loop,level1[loop]);
	end;
	levelPosCounter:=39;
	
	
	Poke(54286,192); 			//enable DLI
	SetIntVec(iDLI, @Dli);	//set dli vector
	SetIntVec(iVBL, @vbl);

	repeat 
		mainLoop;
	 until false;

	
END.

