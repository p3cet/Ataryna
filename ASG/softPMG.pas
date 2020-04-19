unit softPMG;

interface
uses atari;

type
	spriteCol = array [0..15] of byte;
	spriteColPointer = ^spriteCol;
	playerState = (run, jump, shoot, melee, dead);
	
const
	vmem: word = $5100;
	player: array [0..7] of byte = (255,255,255,255,255,255,255,255);

var
	offset: word = 0;
	currVmem: word;
	i: byte;
	
procedure shiftRight (x: byte);
procedure shiftLeft (x: byte);
procedure genLineAddr (vm1: word; vm2: word);

implementation

	procedure genLineAddr (vm1: word; vm2: word);
	begin
	end;

	procedure shiftRight (x: byte);
	begin
		//for i:=0 to 7 do
		//begin
			
		//end;
		currVmem:=vmem+offset;
		Poke(currVmem,player[0] shr x);
		Poke(currVmem+32,player[1] shr x);
		Poke(currVmem+64,player[2] shr x);
		inc(currVmem);
		Poke(currVmem,player[0] shl (8-x));
		Poke(currVmem+32,player[1] shl (8-x));
		Poke(currVmem+64,player[2] shl (8-x));
		
		//inc(offset);
	end;

	procedure shiftLeft (x: byte);
	begin
		//for i:=0 to 7 do
		//begin
			
		//end;
		currVmem:=vmem+offset;
		Poke(currVmem,player[0] shl x);
		dec(currVmem);
		Poke(currVmem,player[0] shr (8-x));
		//inc(offset);
	end;

end.
