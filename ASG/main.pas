program nsg; //new speccy game

uses atari, crt, dls, softPMG, joystick;

Type  
	State = (titleScreen, runGame, death, endGame, pauseGame);


var
	st: State;

begin
	Poke(709,12); // gr.8 luminance	
	Poke(710,4);  // gr.8 background color

	dlLvl1;
	sdmctl:=33;
	genLineAddr(dls.vmem,dls.vmem2);
	genTiles;
	putTile(0,0,0);
	putTile(1,0,1);
	shiftRight(0);
	readkey;

	shiftRight(1);
	fillTileRight(0,1);
	readkey;
	pause;

	shiftRight(2);
	fillTileRight(1,1);
	readkey;
	pause;
	
	shiftRight(3);
	fillTileRight(2,1);
	readkey;
	pause;
	
	dlTitle;
	st:=titleScreen;
	
	{main loop}
	repeat
	case st of
		runGame:	begin;
						if strig0=0 then begin
							dlTitle;
							st:=titleScreen;
							Poke(strig0,1);
						end;
					end;
		titleScreen: begin;
						 writeln('ASG');
						 writeln('Another Speccy Game');
						 writeln('Press fire to start');
						 if strig0=0 then begin
							dlLvl1;
							st:=runGame;
							Poke(strig0,1);
						end;
					end;
		death:		begin;
					end;
		endGame:	begin;
					end;
		pauseGame:	begin;
					end;
	end;
	until keypressed;

end.

//procedure Dli2; interrupt;
//begin
//	asm { phr
//	sta ATARI.WSYNC};
{	colpm0:=$5;
	colpm1:=$2;
	colpm2:=$3;
	colpm3:=$4;
	asm {
	plr };
//end;


//procedure Dli; interrupt;
//begin
//	asm { phr
//	sta ATARI.WSYNC};
{	colpm0:=$16;
	colpm1:=$26;
	colpm2:=$36;
	colpm3:=$46;
	asm { mwa #DLI2 ATARI.VDSLST
	plr };
//end;
