program nsg; //new speccy game

uses atari, crt, dls, softPMG, joystick;

Type  
	State = (titleScreen, runGame, death, endGame, pauseGame);


var
	st: State;
	lb: byte;
	hb: byte;

begin
	Poke(709,12); //<- gr.8 luminance	
	Poke(710,4);	// gr.8 background color

	dlLvl1;
	sdmctl:=33;
	readkey;
	shiftRight(0);
	pause;
	shiftRight(1);
	pause;
	shiftRight(2);
	pause;
	shiftRight(3);
	pause;
	shiftRight(4);
	pause;
	shiftRight(5);
	pause;
	shiftRight(6);
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
