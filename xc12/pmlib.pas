unit pmlib;

interface
uses pmg;

var
	p0Data : array [0.._P_MAX] of byte = (0,0,0,0,32,24,140,255,140,24,32,0,0,0,0);
	p1Data : array [0.._P_MAX] of byte = (0,28,28,56,252,255,240,224,240,60,59,24,4,4,6);
	p2Data : array [0.._P_MAX] of byte = (60,102,110,118,118,118,102,60,24,0,0,0,0,0,0);
	p3Data : array [0.._P_MAX] of byte = (10, 20, 30, 40, 50, 60, 70, 80, 55, 28, 255,0, 0, 0, 0);
	
	 m0Data : array [0.._M0_MAX] of byte = (0,1,0);
	  //m0Data : array [0..19] of byte = (0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0);
	p0Data1 : array [0.._P_MAX] of byte = (0,0,0,0,103,99,61,3,7,227,219,15,6,0,0);
	p1Data1 : array [0.._P_MAX] of byte =  (0,240,112,224,240,240,242,204,240,232,118,12,4,2,3);

	p0PosX: word =80;
	p0PosY: byte =57;
	
	m0PosX: word;
	m0PosY: word;
	
	
procedure loadPlayers;
function moveMissile: byte;
procedure createMissile;
procedure swap;
procedure movePlayer(x: smallint; y: smallint); overload;
implementation

procedure swap;
begin
{	if p_data[0]=@p0Data then begin
		p_data[0]:=@p0Data1;
		p_data[1]:=@p1Data1;
	end
	else begin
		p_data[0]:=@p0Data;
		p_data[1]:=@p1Data;
	end;
}
end;

procedure movePlayer(x: smallint; y: smallint); overload;
begin
	p0PosX:=p0PosX + x;
	p0PosY:=p0PosY + y;
	MoveP(0, p0PosX, p0PosY);
end;

procedure createMissile;
begin
	//delete old missile (poke taken from pmg.pas unit)
	Poke(pm_mem+pm_offset-pm_size+m0PosY+1, 0);
	//set new position
	m0PosX:=p0PosX+10;
	m0PosY:=p0PosY+5;
	//and move
	MoveM(0, m0PosX, m0PosY);
end;

function moveMissile : byte;
begin
	m0PosX:=m0PosX+1;
	if m0PosX>205 then begin
		m0PosX:=0;
		MoveM(0, m0PosX, m0PosY);
		result:=0;
		exit;
	end;
	MoveM(0, m0PosX, m0PosY);
	result:=1;
end;


procedure loadPlayers;
begin
	
	p_data[0]:=@p0Data;
//	p_data[1]:=@p1Data;
//	p_data[2]:=@p2Data;
//	p_data[3]:=@p3Data;

	m_data[0]:=@m0Data;
	
	// Initialize P/M graphics
	SetPM(_PM_SINGLE_RES);
	InitPM(_PM_SINGLE_RES);  
	//Poke(106,Peek(106)-8);
	// Priority register - P/M in front of all playfield
	Poke(623, 33); //44 - player 2-3 under playfield

	// Turn on P/M graphics
	ShowPM(_PM_SHOW_ON);    
  // Draw players
  ColorPM(0, 6);
//  ColorPM(1, 6);
// ColorPM(2, 136);
//  ColorPM(3, 36);

  SizeP(0, _PM_NORMAL_SIZE);
  SizeP(1, _PM_NORMAL_SIZE);
//  SizeP(2, _PM_QUAD_SIZE);
//  SizeP(3, _PM_NORMAL_SIZE);

  MoveP(0, p0PosX, p0PosY);
//  MoveM(0, p0PosX+10, p0PosY);
  
//  MoveP(1, 88, 65);
//  MoveP(2, 100, 85);
//  MoveP(3, 140, 100);
 

	// Reset P/M graphics
	//ShowPM(_PM_SHOW_OFF);        

end;

end.

