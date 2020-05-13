unit softPMG;
	//narrow screen 32 cells in the row
	
interface
uses atari, joystick;
	
type
	level = array [0..2] of byte;
	spriteCol = array [0..15] of byte;
	//spriteColPointer = ^spriteCol; not needed? just make a pointer to spriteCol
	playerState = (run, jump, shoot, melee, dead);
	vertDir = (noneV, up, down);
	horDir = (noneH, left, right);
	//tile = array [0..8] of byte;
	
const
	player: array [0..7] of byte = (255,255,255,255,255,255,255,255);
	level1: level =(0,1,2);

var
	offset: word = 0;
	currVmem: word;
	i: byte;
	lineAddr: array [0..199] of word;
	tileSet: array [0..23] of byte;		//new tile starts every 8th byte
	
	//--PLAYER VARS--//
	plVertDir: vertDir = noneV;
	plHorDir: horDir = noneH;
	plByteX: byte = 0;			//plByteX and plByteY - position of left upper corner of the player sprite
	plByteY: byte = 0;
	plOffsetX: byte = 8;	//8 is default pos - add one to move right, sub 1 to move left, reset on 0 and 15
	plOffsetY: byte = 8;	//8 is default pos - add one to move down, sub 1 to move up, reset on 0 and 15
	//TODO: albo cos na zasadzie direction up right left down i kalkulacja offsetów na podstawie plByteX i plByteY
	
	fillMaskRight: array [0..7] of byte =(127,63,31,15,7,3,1,0);
	fillMaskLeft: array [0..7] of byte = (254,252,248,240,224,192,128,0);
	tempMask: byte =0;
	cell: byte;
	cellX: byte = 0;			//screen is logicaly divided for cells 8x8 pixels
	cellY: byte = 0;			// X and Y gives number of cell horizontaly and verticaly
	
	shift: byte;
	
	//joystick
	joyOffsetX: array [0..15] of smallint = (0,0,0,0,0,1,1,1,0,-1,-1,-1,0,0,0,0);
	joyOffsetY: array [0..15] of smallint = (0,0,0,0,0,1,-1,0,0,1,-1,0,0,1,-1,0);
	joyVal: byte;
	joyOffset: smallint;
	

	
procedure shiftRight (x: byte);
procedure shiftLeft (x: byte);
procedure genLineAddr (vm1: word; vm2: word);
procedure genTiles;
procedure putTile(bx: byte; by: byte; tileNum: byte);
procedure fillTileRight(x: byte; tileNum: byte);
procedure fillTileLeft(x: byte; tileNum: byte);

procedure processJoy;

	
implementation

	procedure genLineAddr (vm1: word; vm2: word);
	begin
		lineAddr[0]:=vm1;
		for i:=1 to 99 do begin
			lineAddr[i]:=lineAddr[i-1]+32;		//wide screen 32 bytes *8 points per byte = 256 points
		end;
		lineAddr[100]:=vm2;
		for i:=101 to 199 do begin
			lineAddr[i]:=lineAddr[i-1]+32;		//wide screen 32 bytes *8 points per byte = 256 points
		end;
	end;
	
	procedure genTiles;
	begin
		tileSet[0]:=170;
		tileSet[1]:=170;
		tileSet[2]:=170;
		tileSet[3]:=170;
		tileSet[4]:=170;
		tileSet[5]:=170;
		tileSet[6]:=170;
		tileSet[7]:=170;
		tileSet[8]:=85;
		tileSet[9]:=85;
		tileSet[10]:=85;
		tileSet[11]:=85;
		tileSet[12]:=85;
		tileSet[13]:=85;
		tileSet[14]:=85;
		tileSet[15]:=85;
		tileSet[16]:=255;
		tileSet[17]:=255;
		tileSet[18]:=255;
		tileSet[19]:=255;
		tileSet[20]:=255;
		tileSet[21]:=255;
		tileSet[22]:=255;
		tileSet[23]:=255;
		
		
		
	end;
	
	procedure movePlayer();
	begin
		//TODO: remove x from shift procedure and set shift value
		//if joy left right
		if plOffsetX>8 then begin
			shift:=plOffsetX-8;
			shiftRight(shift);
		end
		else begin
			shift:=plOffsetX;
			shiftLeft(shift);
		end;
	end;
	
	procedure shiftRight (x: byte);
	begin
		for i:=0 to 7 do begin
			Poke(lineAddr[plByteY+i]+plByteX, player[i] shr x);
			Poke(lineAddr[plByteY+i]+plByteX+1, player[i] shl (8-x));
		end;
	end;

	procedure shiftLeft (x: byte);
	begin
		for i:=0 to 7 do begin
			Poke(lineAddr[plByteY+i]+plByteX, player[i] shl x);
			Poke(lineAddr[plByteY+i]+plByteX-1, player[i] shr (8-x));
		end;
	end;

	procedure putTile(bx: byte; by: byte; tileNum: byte);
	begin
		tileNum:=tileNum*8;
		for i:=0 to 7 do
			Poke(lineAddr[by+i]+bx,tileSet[tileNum+i]);
	end;
	
	procedure fillTileRight(x: byte; tileNum: byte);
	begin
		tileNum:=tileNum*8;
		for i:=0 to 7 do begin
			tempMask:=tileSet[tileNum+i] AND fillMaskRight[x];	//clear last x bits of the tile
			cell:= Peek(lineAddr[plByteY+i]+plByteX+1) OR tempMask; //mix mask and the part of the sprite written in the byte
			Poke(lineAddr[plByteY+i]+plByteX+1,cell);	 //add one to bx, because cell on the RIGHT side has to be filled
		end;
	end;

	procedure fillTileLeft(x: byte; tileNum: byte);		//TODO: copy pasted from fillTileRight, if something goes wrong check it first
	begin
		tileNum:=tileNum*8;
		for i:=0 to 7 do begin
			tempMask:=tileSet[tileNum+i] AND fillMaskRight[x];	//clear first x bits of the tile
			cell:= Peek(lineAddr[plByteY+i]+plByteX-1) OR tempMask; //mix mask and the part of the sprite written in the byte
			Poke(lineAddr[plByteY+i]+plByteX-1,cell);	 //sub one from bx, because cell on the LEFT side has to be filled
		end;
	end;

procedure processJoy;
	begin
		joyVal:=stick0;	//TODO: remove? replace with joyOffsetX[stick0] 
		joyOffset:=joyOffsetX[joyVal];
		//TODO: check if move is possible
		
		//update player position
		plOffsetX:=plOffsetX+joyOffset;		//TODO: check - add smallint to byte
		if (plOffsetX=8) and (joyOffset=1) then inc(plByteX)
		else if plOffsetX=255  then
		begin
			plOffsetX:=15; //reset plOffsetX
			dec(plByteX);
		end
		else if plOffsetX=16 then
		begin
			plOffsetX:=8; //reset plOffsetX
			inc(plByteX);
		end; 
		
		joyOffset:=joyOffsetY[joyVal];
		plOffsetY:=plOffsetY+joyOffset;
		if (plOffsetY=255) then plOffsetY:=7
		else if plOffsetY=16 then plOffsetY:=8; //reset plOffsetY 
		plByteY:=plByteY+joyOffset;
		
	end;

end.
