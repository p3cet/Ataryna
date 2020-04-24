unit softPMG;

interface
uses atari;

type
	level = array [0..2] of byte;
	spriteCol = array [0..15] of byte;
	//spriteColPointer = ^spriteCol; not needed? just make a pointer to spriteCol
	playerState = (run, jump, shoot, melee, dead);
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
	byteX: byte = 0;
	byteY: byte = 0;
	fillMaskRight: array [0..7] of byte =(127,63,31,15,7,3,1,0);
	fillMaskLeft: array [0..7] of byte = (254,252,248,240,224,192,128,0);
	tempMask: byte =0;
	cell: byte;
	cellX: byte = 0;			//screen is logicaly divided for cells 8x8 pixels
	cellY: byte = 0;			// X and Y gives number of cell horizontaly and verticaly
	
procedure shiftRight (x: byte);
procedure shiftLeft (x: byte);
procedure genLineAddr (vm1: word; vm2: word);
procedure genTiles;
procedure putTile(bx: byte; by: byte; tileNum: byte);
//procedure fillTileRight(bx: byte; by: byte; x: byte; tileNum: byte);
procedure fillTileRight(x: byte; tileNum: byte);
	
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

	procedure shiftRight (x: byte);
	begin
		for i:=0 to 7 do begin
			Poke(lineAddr[byteY+i]+byteX, player[i] shr x);
			Poke(lineAddr[byteY+i]+byteX+1, player[i] shl (8-x));
		end;
	end;

	procedure shiftLeft (x: byte);
	begin
		for i:=0 to 7 do begin
			Poke(lineAddr[byteY+i]+byteX, player[i] shl x);
			Poke(lineAddr[byteY+i]+byteX-1, player[i] shr (8-x));
		end;
	end;

	procedure putTile(bx: byte; by: byte; tileNum: byte);
	begin
		tileNum:=tileNum*8;
		for i:=0 to 7 do
			Poke(lineAddr[by+i]+bx,tileSet[tileNum+i]);
	end;
	
	//procedure fillTileRight(bx: byte; by: byte; x: byte; tileNum: byte);
	procedure fillTileRight(x: byte; tileNum: byte);
	begin
		tileNum:=tileNum*8;
		for i:=0 to 7 do begin
			tempMask:=tileSet[tileNum+i] AND fillMaskRight[x];	//clear first x bits of the tile
			cell:= Peek(lineAddr[byteY+i]+byteX+1) OR tempMask;
			Poke(lineAddr[byteY+i]+byteX+1,cell);	 //add one to bx cell on the RIGHT side has to be filled  OR tempMask
		
		end;
	end;
end.
